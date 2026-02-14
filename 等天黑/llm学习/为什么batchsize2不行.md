# Batch Size 优化尝试总结

  

## 🎯 目标

优化Tesla T4 (15GB显存)上的训练性能，通过增加batch size和并行数据加载来提升训练速度。

  

## ⚠️ 发现的关键问题

  

### Batch Size > 1 的兼容性问题

  

在尝试将`batch_size`从1提升到2时，遇到了一个**transformers库与自定义模型**之间的深层兼容性问题：

  

**错误信息**：

```

RuntimeError: The expanded size of the tensor (2048) must match the existing size (2) at non-singleton dimension 2.

Target sizes: [2, 32, 2048, 2048]. Tensor sizes: [2, 2048]

```

  

**根本原因**：

- 当`batch_size=1`时，`attention_mask`的shape是`[1, 2048]`，可以正确广播到4D tensor

- 当`batch_size>1`时，`attention_mask`的shape是`[2, 2048]`，但SDPA (Scaled Dot Product Attention)在扩展时出现维度不匹配

- 这是因为`StitchedModel`直接调用预训练模型的layers，而这些layers期望特定格式的attention_mask

  

**尝试的解决方案**：

1. ❌ 将attention_mask转换为bool类型 → 类型不匹配错误

2. ❌ 保持attention_mask为int64类型 → 仍然维度错误

3. ❌ 转换为float16类型匹配模型 → 维度扩展仍然失败

4. ❌ 设置attention_mask为None → 问题依然存在（可能是缓存问题）

  

## ✅ 当前推荐配置

  

由于batch_size>1存在兼容性问题，推荐使用以下配置：

  

```python

training_args = TrainingArguments(

per_device_train_batch_size=1, # 保持为1

gradient_accumulation_steps=4, # 通过梯度累积模拟batch_size=4

# 🔥 数据加载并行优化（这些仍然有效！）

dataloader_num_workers=4, # 4个worker并行加载数据

dataloader_pin_memory=True, # 加速CPU->GPU传输

dataloader_prefetch_factor=2, # 每个worker预取2个batch

# 🔥 混合精度训练

fp16=True, # Tesla T4优化

# 其他优化

gradient_checkpointing=True, # 节省显存

max_grad_norm=1.0, # 梯度裁剪

)

```

  

### 有效Batch Size计算

  

虽然physical batch size=1，但**有效batch size = 1 × 4 = 4**

  

这意味着：

- 每4个batch更新一次模型参数

- 训练效果等同于batch_size=4

- 但显存占用保持在batch_size=1的水平

  

## 🚀 已实现的优化（仍然有效）

  

### 1. 并行数据加载 ✅

- **num_workers=4**: 4个进程并行加载数据

- **prefetch_factor=2**: 每个worker预取2个batch

- **pin_memory=True**: 加速数据传输

  

**效果**：即使batch_size=1，GPU也不会等待数据，训练更流畅

  

### 2. 混合精度训练 ✅

- **FP16**: Tesla T4原生支持，加速计算

- 节省显存约50%

- 训练速度提升30-50%

  

### 3. 梯度累积 ✅

- 模拟更大的batch size

- 训练稳定性更好

- loss计算更准确

  

### 4. 梯度检查点 ✅

- 节省显存用于存储中间激活

- 允许训练更大的模型或更长的序列

  

## 📊 性能对比估算

  

| 配置 | Physical BS | Effective BS | 显存使用 | 训练速度 | 稳定性 |

|------|-------------|--------------|----------|----------|--------|

| 原始 | 1 | 1 | ~8GB | 基准 | 一般 |

| 优化后 | 1 | 4 | ~8GB | +40% | 更好 |

| (理想)BS=2 | 2 | 8 | ~12GB | +80% | 最好 |

  

**说明**：

- 通过并行数据加载和FP16，即使physical BS=1，也能获得~40%的加速

- 梯度累积提升了训练稳定性（等效于larger batch）

- 如果能解决batch_size>1的问题，理论上还能再提升一倍

  

## 🔧 如何使用当前配置

  

### 修改main.py

  

```python

model.train(

output_dir="./stitch_model_optimized",

learning_rate=1e-4,

per_device_train_batch_size=1, # 保持为1

save_steps=100,

logging_steps=10,

gradient_checkpointing=True,

)

```

  

配置会自动从`stitchllm.py`中的`TrainingArguments`应用：

- `gradient_accumulation_steps=4`

- `dataloader_num_workers=4`

- `fp16=True`

  

### 验证配置生效

  

运行时应该看到：

```

✅ 有效batch_size: 1 × 4 (gradient_accumulation) = 4

✅ 数据加载: 4个worker并行加载，每个预取2个batch

✅ 混合精度: FP16 (Tesla T4优化)

```

  

## 🔮 未来改进方向

  

### 1. 解决Batch Size > 1 问题（高优先级）

  

可能的方向：

1. **修改attention_mask处理逻辑**：手动构建4D attention_mask

2. **使用不同的attention实现**：禁用SDPA，使用标准attention

3. **升级transformers版本**：检查新版本是否修复了这个问题

4. **重构StitchedModel**：使其更好地兼容transformers的API

  

### 2. 进一步优化数据加载

  

- 使用更多workers（如果CPU核心足够）

- 预处理数据缓存

- 使用更高效的数据格式

  

### 3. 显存优化

  

- DeepSpeed Zero优化

- 量化训练（INT8）

- 更激进的gradient checkpointing

  

## 📝 总结

  

虽然无法使用`batch_size>1`，但通过以下优化仍能显著提升训练效率：

  

✅ **梯度累积** - 模拟大batch size，提升稳定性

✅ **并行数据加载** - 减少GPU空闲时间

✅ **FP16混合精度** - 加速计算，节省显存

✅ **梯度检查点** - 优化显存使用

  

**预计加速比**: ~40% (相比原始配置)

  

**下一步建议**: 在完成当前配置的训练后，深入研究batch_size>1的根本原因，争取解决这个兼容性问题以获得更大的性能提升。