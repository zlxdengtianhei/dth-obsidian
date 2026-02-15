"""

Copyright (c) 2022, salesforce.com, inc.

All rights reserved.

SPDX-License-Identifier: BSD-3-Clause

For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause

"""

  

import torch

import torch.nn.functional as F

from lavis.common.registry import registry

from lavis.models.blip_models.blip_image_text_matching import BlipITM, compute_gradcam

from lavis.models.vit import VisionTransformerEncoder

from lavis.models.med import XBertEncoder

import numpy as np

import os

import sys

import gc

from PIL import Image

from scipy.ndimage import zoom

  

# 添加EfficientSAM的路径

sys.path.append(os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__)))), 'EfficientSAM'))

from efficient_sam.build_efficient_sam import build_efficient_sam_vitt, build_efficient_sam_vits

  
  

@registry.register_model("blip_esam_itm")

class BlipESamITM(BlipITM):

"""

BLIP Image-Text Matching (ITM) model with EfficientSAM integration.

This model first uses the BLIP ITM model to generate a heatmap, then uses

the heatmap to select points for EfficientSAM to generate a more refined mask.

"""

  

PRETRAINED_MODEL_CONFIG_DICT = {

"base": "configs/models/blip_esam_itm_base.yaml",

"large": "configs/models/blip_esam_itm_large.yaml",

}

  

def __init__(self, image_encoder, text_encoder, embed_dim=256, max_txt_len=35):

super().__init__(image_encoder, text_encoder, embed_dim, max_txt_len)

# 获取library_root的父目录（应该是/workspace/LAVIS_EfficientSAM）

lavis_root = registry.get_path("library_root")

base_dir = os.path.dirname(lavis_root)

# 构建权重路径，使用vits替代vitt

weight_path = os.path.join(base_dir, 'EfficientSAM/weights/efficient_sam_vits.pt')

# 检查权重文件是否存在

if not os.path.exists(weight_path):

# 尝试在repo_root下查找

alt_weight_path = os.path.join(registry.get_path("repo_root"), 'EfficientSAM/weights/efficient_sam_vits.pt')

if os.path.exists(alt_weight_path):

weight_path = alt_weight_path

else:

print(f"Warning: EfficientSAM vits weights not found at {weight_path} or {alt_weight_path}")

weight_path = None

# 初始化EfficientSAM模型，使用更小的vits变体

print(f"Loading EfficientSAM vits variant with weights from {weight_path}")

self.efficient_sam = build_efficient_sam_vits(checkpoint=weight_path)

self.efficient_sam.eval() # 设置为评估模式

# 设置处理参数

self.num_points = 5 # 选择的点数量

self.use_small_input = True # 设置使用小尺寸输入的标志

# 用于CUDA内存监控

self.print_memory_usage = True

# 保持EfficientSAM在GPU上运行以提高性能

# self.efficient_sam = self.efficient_sam.cpu() # 注释掉此行

  

def print_gpu_memory(self, message=""):

"""打印GPU内存使用情况"""

if self.print_memory_usage:

if message:

print(f"\n{message}")

print(f"GPU memory allocated: {torch.cuda.memory_allocated() / 1024**2:.2f} MB")

print(f"GPU memory reserved: {torch.cuda.memory_reserved() / 1024**2:.2f} MB")

print(f"GPU max memory allocated: {torch.cuda.max_memory_allocated() / 1024**2:.2f} MB")

  

def clear_gpu_memory(self):

"""清理GPU内存"""

gc.collect()

torch.cuda.empty_cache()

if self.print_memory_usage:

print("Cleared GPU memory")

self.print_gpu_memory()

  

def extract_points_from_heatmap(self, heatmap, num_points=5):

"""

从热力图中提取最显著的点作为EfficientSAM的输入点

Args:

heatmap: 形状为 [H, W] 的热力图

num_points: 要提取的点数量

Returns:

points: 形状为 [num_points, 2] 的点坐标 (x, y)

labels: 形状为 [num_points] 的点标签 (1 表示前景)

point_scores: 每个点的重要性分数

"""

# 确保热力图是CPU上的numpy数组

if isinstance(heatmap, torch.Tensor):

heatmap_np = heatmap.detach().cpu().numpy()

else:

heatmap_np = heatmap

# 找到热力图中的最高值位置

# 为了增加多样性，我们不仅选择最高值，还进行一些聚类采样

# 首先平滑热力图以避免噪声

from scipy.ndimage import gaussian_filter

smoothed_heatmap = gaussian_filter(heatmap_np, sigma=1.0)

# 创建点和标签列表

points = []

point_scores = [] # 用于记录每个点的重要性

# 迭代提取点

remaining_heatmap = smoothed_heatmap.copy()

for i in range(num_points):

# 找到当前热力图中的最高值位置

y, x = np.unravel_index(np.argmax(remaining_heatmap), remaining_heatmap.shape)

score = remaining_heatmap[y, x]

# 如果热力图中所有值都为零，则在中心和四个角落放置点

if score <= 0 and i == 0:

h, w = remaining_heatmap.shape

# 中心点

points.append((w // 2, h // 2))

point_scores.append(1.0) # 给中心点最高分

# 四个角落及周围

corner_points = [

(w // 4, h // 4), # 左上角

(w * 3 // 4, h // 4), # 右上角

(w // 4, h * 3 // 4), # 左下角

(w * 3 // 4, h * 3 // 4), # 右下角

]

# 添加其余的角落点

for j, corner in enumerate(corner_points):

if i + j + 1 < num_points:

points.append(corner)

point_scores.append(0.9 - j * 0.1) # 依次降低角落点的分数

# 如果点数已经足够，跳出循环

if len(points) >= num_points:

points = points[:num_points]

point_scores = point_scores[:num_points]

break

# 跳过当前的循环，因为我们已经有了中心点

continue

# 添加到结果列表

points.append((x, y))

point_scores.append(float(score)) # 确保转换为Python浮点数

# 从热力图中"移除"这个区域，防止选择过近的点

# 创建一个距离图，与选定点的距离越近，减少的值越大

y_indices, x_indices = np.ogrid[:remaining_heatmap.shape[0], :remaining_heatmap.shape[1]]

dist_from_point = np.sqrt((x_indices - x)**2 + (y_indices - y)**2)

mask = np.exp(-dist_from_point / 5.0) # 距离衰减因子

remaining_heatmap -= mask * score

# 确保不会出现负值

remaining_heatmap = np.maximum(remaining_heatmap, 0)

# 转换为numpy数组

points = np.array(points)

# 打印用于调试

print(f"点坐标和分数:")

for i, (point, score) in enumerate(zip(points, point_scores)):

print(f" 点 {i+1}: 坐标={point}, 得分={score:.6f}")

# 所有点都标记为前景 (1)

labels = np.ones(num_points)

return points, labels, point_scores

  

def scale_points_to_image_size(self, points, orig_size, target_size):

"""

将热力图上的点坐标缩放到原始图像大小

Args:

points: 形状为 [num_points, 2] 的点坐标 (x, y)

orig_size: 热力图的大小 (高度, 宽度)

target_size: 目标图像的大小 (高度, 宽度)

Returns:

scaled_points: 缩放后的点坐标

"""

# 计算缩放因子

scale_y = target_size[0] / orig_size[0]

scale_x = target_size[1] / orig_size[1]

# 应用缩放

scaled_points = points.copy()

scaled_points[:, 0] = points[:, 0] * scale_x # x坐标

scaled_points[:, 1] = points[:, 1] * scale_y # y坐标

return scaled_points

  

def enhance_heatmap_with_mask(self, heatmap, mask, alpha=0.5):

"""

使用EfficientSAM分割掩码增强原始热力图

Args:

heatmap: 原始热力图, 形状为 [H, W]

mask: 分割掩码, 形状为 [H, W]

alpha: 融合因子，控制原始热力图与掩码融合的比例

Returns:

enhanced_heatmap: 增强后的热力图

"""

# 确保为numpy数组

if isinstance(heatmap, torch.Tensor):

heatmap = heatmap.detach().cpu().numpy()

if isinstance(mask, torch.Tensor):

mask = mask.detach().cpu().numpy()

# 确保数据类型为float32，这是scipy.ndimage.zoom支持的类型

heatmap = heatmap.astype(np.float32)

mask = mask.astype(np.float32)

# 确保掩码是2D的，如果有额外的维度则进行压缩

if mask.ndim > 2:

# 如果是3D，可能是多通道掩码，取第一个通道

mask = mask[0] if mask.shape[0] == 1 else np.mean(mask, axis=0)

# 如果尺寸不匹配，将掩码缩放到热力图大小

if heatmap.shape != mask.shape:

try:

mask = zoom(mask, (heatmap.shape[0] / mask.shape[0], heatmap.shape[1] / mask.shape[1]), order=1)

except Exception as e:

print(f"在zoom操作中出错: {e}, mask.shape={mask.shape}, heatmap.shape={heatmap.shape}, mask.dtype={mask.dtype}")

# 创建一个与热力图相同大小的全零掩码作为后备

mask = np.zeros_like(heatmap)

# 将掩码标准化到 [0, 1]

if mask.max() > 1.0:

mask = mask / 255.0

# 增强热力图: 原始热力图与掩码的加权组合

enhanced_heatmap = alpha * heatmap + (1 - alpha) * mask

# 再次标准化热力图

if enhanced_heatmap.max() > enhanced_heatmap.min(): # 避免除以零

enhanced_heatmap = (enhanced_heatmap - enhanced_heatmap.min()) / (enhanced_heatmap.max() - enhanced_heatmap.min() + 1e-8)

return enhanced_heatmap

  

def forward(self, samples, match_head="itm"):

"""

Forward pass with BLIP ITM and EfficientSAM integration.

Args:

samples: Dictionary containing image and text inputs

match_head: Type of matching head to use (default: "itm")

Returns:

tuple: (blip_output, gradcams) if enhanced heatmaps were generated,

or just blip_output otherwise

"""

self.print_gpu_memory("初始内存状态")

# 检查是否已有热力图或正在递归处理 - 避免无限递归

if 'gradcams' in samples or 'original_heatmaps' in samples or samples.get('_processing', False) or samples.get('_gradcam_processing', False):

print("热力图已存在或正在处理中，跳过EfficientSAM处理")

# 只运行BLIP的forward，不递归处理热力图

return super().forward(samples, match_head)

# 标记正在处理，避免后续递归调用问题

samples = samples.copy() # 创建一个副本，避免修改原始字典

samples['_processing'] = True

# 存储增强的热力图

enhanced_gradcams = None

try:

# 首先获取BLIP ITM的原始输出

blip_output = super().forward(samples, match_head)

# 只在ITM模式下使用EfficientSAM

if match_head != "itm":

# 移除处理标记

if '_processing' in samples:

del samples['_processing']

return blip_output

image = samples["image"]

batch_size = image.size(0)

# 释放不再需要的变量以节省内存

self.clear_gpu_memory()

try:

# 在自动混合精度模式下执行，减少内存使用

with torch.cuda.amp.autocast(enabled=True):

# 获取热力图

with torch.set_grad_enabled(True):

self.print_gpu_memory("生成热力图前")

caption = samples["text_input"]

tokenized_text = self.tokenizer(

caption, padding="longest", truncation=True, max_length=self.max_txt_len, return_tensors="pt"

).to(image.device)

# 计算热力图 - 注意这里的热力图是在特征图尺寸(24x24)上的

try:

print("计算BLIP ITM热力图...")

gradcams, _ = compute_gradcam(

model=self,

visual_input=image,

text_input=caption,

tokenized_text=tokenized_text,

block_num=7

)

# 收集热力图 - 只取索引1的热力图（代表平均过的跨token热力图）

heat_maps = torch.stack([gradcam_[1] for gradcam_ in gradcams]) # [batch_size, 24, 24]

heat_h, heat_w = heat_maps.shape[1], heat_maps.shape[2]

print(f"原始热力图尺寸: {heat_h}x{heat_w}")

except Exception as e:

print(f"计算热力图时出错: {e}")

# 创建一个统一的热力图作为后备方案

heat_h, heat_w = 24, 24

heat_maps = torch.ones((batch_size, heat_h, heat_w), device=image.device)

print("使用均匀分布热力图作为后备")

# 保存原始热力图到samples

samples['original_heatmaps'] = heat_maps.clone()

self.print_gpu_memory("热力图生成后")

# 释放内存

del tokenized_text

self.clear_gpu_memory()

# 处理每个样本 - 使用GPU处理以提高性能

enhanced_heat_maps = []

for b in range(batch_size):

print(f"\n处理批次中的样本 {b+1}/{batch_size}")

# 1. 从热力图中提取最显著的点

curr_heatmap = heat_maps[b].cpu()

points, point_labels, point_scores = self.extract_points_from_heatmap(

curr_heatmap,

num_points=self.num_points

)

print(f"从热力图中提取了 {len(points)} 个点")

for i, (pt, score) in enumerate(zip(points, point_scores)):

print(f" 点 {i+1}: 坐标={pt}, 得分={score:.4f}")

# 2. 获取图像并缩小尺寸以减少内存使用

curr_image = image[b].clone() # [C, H, W]

# 如果图像尺寸过大，可以降低分辨率

orig_h, orig_w = curr_image.shape[1], curr_image.shape[2]

max_size = 384 # 最大尺寸限制

if orig_h > max_size or orig_w > max_size:

# 计算缩放比例

scale = min(max_size / orig_h, max_size / orig_w)

new_h, new_w = int(orig_h * scale), int(orig_w * scale)

# 缩放图像

curr_image = F.interpolate(

curr_image.unsqueeze(0), # 添加批次维度

size=(new_h, new_w),

mode='bilinear',

align_corners=False

).squeeze(0) # 移除批次维度

print(f"图像尺寸已从 {orig_h}x{orig_w} 缩放到 {new_h}x{new_w}")

# 缩放点坐标到图像大小

img_h, img_w = curr_image.shape[1], curr_image.shape[2]

scaled_points = self.scale_points_to_image_size(

points,

(heat_h, heat_w),

(img_h, img_w)

)

# 准备EfficientSAM输入 - 使用GPU处理

with torch.no_grad():

# 转换为EfficientSAM所需的格式

# batched_points的期望形状: [B, num_queries, num_pts, 2]

# 在我们的情况下: B=1, num_queries=1, num_pts=num_points

input_points = torch.from_numpy(scaled_points).float().to(curr_image.device)

# 添加查询维度 [num_points, 2] -> [1, num_points, 2]

input_points = input_points.unsqueeze(0) # 添加查询维度

# 进一步添加批次维度 [1, num_points, 2] -> [1, 1, num_points, 2]

input_points = input_points.unsqueeze(0)

# 使用点的分数来生成标签，而不是统一设置为1

# 将分数归一化到[0.1, 1.0]范围内作为权重

normalized_scores = np.array(point_scores)

if len(normalized_scores) > 0 and np.max(normalized_scores) > np.min(normalized_scores):

normalized_scores = 0.1 + 0.9 * (normalized_scores - np.min(normalized_scores)) / (np.max(normalized_scores) - np.min(normalized_scores))

else:

normalized_scores = np.ones_like(normalized_scores)

# 使用归一化分数作为正标签(1)的权重

input_labels = torch.from_numpy(normalized_scores).float().to(curr_image.device)

# 同样添加维度 [num_points] -> [1, 1, num_points]

input_labels = input_labels.unsqueeze(0).unsqueeze(0)

print("使用归一化的点分数作为标签权重:")

for i, score in enumerate(normalized_scores):

print(f" 点 {i+1}: 原始得分={point_scores[i]:.4f}, 归一化得分={score:.4f}")

# 准备图像输入

input_image = curr_image.unsqueeze(0) # [1, C, H, W]

# 确保EfficientSAM在GPU上运行

self.efficient_sam = self.efficient_sam.to(curr_image.device)

# 输出点和标签的形状以便调试

print(f"输入点形状: {input_points.shape}")

print(f"输入标签形状: {input_labels.shape}")

print(f"输入图像形状: {input_image.shape}")

print("在GPU上运行EfficientSAM...")

try:

# 运行EfficientSAM模型 - 正确设置参数

masks, iou_predictions = self.efficient_sam(

input_image, # [1, C, H, W]

input_points, # [1, 1, num_points, 2]

input_labels, # [1, 1, num_points]

scale_to_original_image_size=True # 使用正确的参数

)

print(f"EfficientSAM完成，掩码形状: {masks.shape}, IoU预测: {iou_predictions}")

# 获取掩码 - 形状应为 [B, num_queries, num_masks, H, W]

# 我们取第一个批次、第一个查询、第一个掩码

mask = masks[0, 0, 0] # [H, W]

# 使用掩码增强热力图

enhanced_heatmap = self.enhance_heatmap_with_mask(

curr_heatmap.numpy(),

mask.cpu().numpy()

)

# 转换回tensor

enhanced_heatmap_tensor = torch.from_numpy(enhanced_heatmap).to(image.device)

enhanced_heat_maps.append(enhanced_heatmap_tensor)

print("热力图增强完成")

except Exception as e:

print(f"EfficientSAM处理出错: {e}")

import traceback

traceback.print_exc()

# 如果处理失败，使用原始热力图

enhanced_heat_maps.append(curr_heatmap.to(image.device))

# 清理本次迭代的内存

del curr_image, input_image, input_points, input_labels

if 'masks' in locals():

del masks

if 'iou_predictions' in locals():

del iou_predictions

self.clear_gpu_memory()

# 将增强的热力图堆叠成批处理张量

if enhanced_heat_maps:

enhanced_heat_maps = torch.stack(enhanced_heat_maps)

# 将增强的热力图扁平化并保存

enhanced_gradcams = enhanced_heat_maps

samples['gradcams'] = enhanced_heat_maps.view(batch_size, -1)

print(f"已保存增强热力图，形状: {enhanced_heat_maps.shape}")

else:

# 如果没有成功处理任何样本，使用原始热力图

enhanced_gradcams = heat_maps

samples['gradcams'] = heat_maps.view(batch_size, -1)

print("使用原始热力图作为后备")

self.print_gpu_memory("处理完成")

# 移除处理标记

if '_processing' in samples:

del samples['_processing']

# 返回两个输出：BLIP ITM输出和增强的热力图

return blip_output, enhanced_gradcams

except Exception as e:

print(f"整体处理过程中出错: {e}")

import traceback

traceback.print_exc()

# 如果samples中没有gradcams，添加一个空的

if 'gradcams' not in samples:

# 创建一个统一的热力图

heat_h, heat_w = 24, 24

heat_maps = torch.ones((batch_size, heat_h, heat_w), device=image.device)

samples['gradcams'] = heat_maps.view(batch_size, -1)

enhanced_gradcams = heat_maps

# 移除处理标记

if '_processing' in samples:

del samples['_processing']

# 返回原始输出和热力图

return blip_output, enhanced_gradcams if enhanced_gradcams is not None else heat_maps

finally:

# 确保无论如何都移除处理标记

if '_processing' in samples:

del samples['_processing']

# 如果没有增强热力图，只返回BLIP输出

return blip_output

  

@classmethod

def from_config(cls, cfg=None):

# 使用BlipITM的from_config方法

image_encoder = VisionTransformerEncoder.from_config(cfg)

if cfg.get("text_encoder", "") == "bert-large-uncased":

# 大型BERT模型

text_encoder = XBertEncoder.from_config(cfg)

else:

# 默认使用base尺寸的BERT模型

text_encoder = XBertEncoder.from_config(cfg)

embed_dim = cfg.get("embed_dim", 256)

max_txt_len = cfg.get("max_txt_len", 35)

model = cls(

image_encoder=image_encoder,

text_encoder=text_encoder,

embed_dim=embed_dim,

max_txt_len=max_txt_len,

)

# 加载预训练检查点（如果配置中有指定）

if cfg.get("load_finetuned", False) and hasattr(cfg, "finetuned"):

model.load_checkpoint_from_config(cfg)

return model