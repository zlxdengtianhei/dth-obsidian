#!/usr/bin/env python3

"""

实验1：控制变量 - 只改损失函数，保持原网络结构

目标：验证QR分解是否是梯度阻断的根本原因

"""

import numpy as np

import torch

import torch.nn as nn

import torch.optim as optim

from torch.utils.data import DataLoader, TensorDataset

from model_profiler import get_avg_flops

  

class OriginalSVDNetwork(nn.Module):

"""

原始网络结构，但训练时移除QR分解

"""

def __init__(self, M=64, r=32, hidden_dim=512):

super(OriginalSVDNetwork, self).__init__()

self.M = M

self.r = r

# 保持原来的网络结构：简单MLP

input_dim = 2 * M * M # 只用原始矩阵，不加Gram

self.feature_extractor = nn.Sequential(

nn.Linear(input_dim, hidden_dim),

nn.ReLU(),

nn.Linear(hidden_dim, hidden_dim),

nn.ReLU(),

nn.Linear(hidden_dim, hidden_dim),

nn.ReLU()

)

# F矩阵输出头 (64×32)

self.f_head = nn.Linear(hidden_dim, 2 * M * r)

# G矩阵输出头 (32×64)

self.g_head = nn.Linear(hidden_dim, 2 * r * M)

def forward(self, x_complex):

"""

前向传播 - 训练时不做QR，推理时做QR

"""

batch_size = x_complex.shape[0]

# 保持原来的输入处理：只用原始矩阵

x_real = torch.cat([x_complex.real.view(batch_size, -1),

x_complex.imag.view(batch_size, -1)], dim=1)

# 特征提取

features = self.feature_extractor(x_real)

# 生成F矩阵 (64×32)

f_output = self.f_head(features)

f_real = f_output[:, :self.M * self.r].view(batch_size, self.M, self.r)

f_imag = f_output[:, self.M * self.r:].view(batch_size, self.M, self.r)

F_raw = torch.complex(f_real, f_imag)

# 关键改动：训练时不做QR，推理时才做QR

if self.training:

F = F_raw # 训练时使用原始F

else:

F = self.make_orthogonal(F_raw) # 推理时QR正交化

# 生成G矩阵 (32×64)

g_output = self.g_head(features)

g_real = g_output[:, :self.r * self.M].view(batch_size, self.r, self.M)

g_imag = g_output[:, self.r * self.M:].view(batch_size, self.r, self.M)

G = torch.complex(g_real, g_imag)

return F, G

def make_orthogonal(self, F_raw):

"""推理时QR正交化"""

batch_size = F_raw.shape[0]

F_ortho = torch.zeros_like(F_raw)

for i in range(batch_size):

Q, R = torch.linalg.qr(F_raw[i])

F_ortho[i] = Q

return F_ortho

  

class ComplexDataManager:

"""数据管理 - 保持不变"""

def __init__(self):

self.mean_real = 0

self.mean_imag = 0

self.std_real = 1

self.std_imag = 1

def fit_normalization(self, data_complex):

self.mean_real = data_complex.real.mean()

self.mean_imag = data_complex.imag.mean()

self.std_real = data_complex.real.std()

self.std_imag = data_complex.imag.std()

print(f"归一化参数 - 实部: 均值={self.mean_real:.6f}, 标准差={self.std_real:.6f}")

print(f"归一化参数 - 虚部: 均值={self.mean_imag:.6f}, 标准差={self.std_imag:.6f}")

def normalize(self, data_complex):

real_norm = (data_complex.real - self.mean_real) / self.std_real

imag_norm = (data_complex.imag - self.mean_imag) / self.std_imag

return torch.complex(real_norm, imag_norm)

def denormalize(self, data_complex):

real_denorm = data_complex.real * self.std_real + self.mean_real

imag_denorm = data_complex.imag * self.std_imag + self.mean_imag

return torch.complex(real_denorm, imag_denorm)

  

def experiment_loss_function(H_pred, H_true, F_raw, G, alpha=0.1, beta=0.1):

"""

实验损失函数：调低正交约束权重

"""

# 1. 重构损失

recon_loss = torch.mean(torch.abs(H_pred - H_true) ** 2)

# 2. F软正交损失 (权重调低)

batch_size, M, r = F_raw.shape

I = torch.eye(r, dtype=F_raw.dtype, device=F_raw.device).unsqueeze(0).expand(batch_size, -1, -1)

F_gram = torch.matmul(F_raw.conj().transpose(-1, -2), F_raw)

ortho_loss_F = torch.mean(torch.abs(F_gram - I) ** 2)

# 3. G正交损失 (权重调低)

G_gram = torch.matmul(G, G.conj().transpose(-1, -2))

mask = ~torch.eye(r, dtype=torch.bool, device=G.device).unsqueeze(0).expand(batch_size, -1, -1)

off_diagonal = G_gram[mask]

ortho_loss_G = torch.mean(torch.abs(off_diagonal) ** 2)

total_loss = recon_loss + alpha * ortho_loss_F + beta * ortho_loss_G

return total_loss, recon_loss, ortho_loss_F, ortho_loss_G

  

def load_data():

"""加载数据"""

print("=== 加载数据 ===")

train_data = np.load('CompetitionData1/Round1TrainData1.npy')

train_label = np.load('CompetitionData1/Round1TrainLabel1.npy')

test_data = np.load('CompetitionData1/MyTestData.npy')

test_label = np.load('CompetitionData1/MyTestLabel.npy')

print(f"训练数据形状: {train_data.shape}")

# 转换为复数张量

train_complex = torch.complex(

torch.from_numpy(train_data[..., 0]),

torch.from_numpy(train_data[..., 1])

)

train_label_complex = torch.complex(

torch.from_numpy(train_label[..., 0]),

torch.from_numpy(train_label[..., 1])

)

test_complex = torch.complex(

torch.from_numpy(test_data[..., 0]),

torch.from_numpy(test_data[..., 1])

)

test_label_complex = torch.complex(

torch.from_numpy(test_label[..., 0]),

torch.from_numpy(test_label[..., 1])

)

return train_complex, train_label_complex, test_complex, test_label_complex

  

def calculate_L_AE(predictions, targets):

"""计算L_AE"""

diff_norm = torch.norm(predictions - targets, dim=(1, 2))

target_norm = torch.norm(targets, dim=(1, 2))

relative_error = diff_norm / (target_norm + 1e-8)

return relative_error.mean().item()

  

def run_experiment1():

"""运行实验1：只改损失函数"""

print("=== 实验1：只改损失函数，验证QR分解影响 ===")

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

print(f"使用设备: {device}")

# 加载数据

train_data, train_labels, test_data, test_labels = load_data()

# 归一化

data_manager = ComplexDataManager()

data_manager.fit_normalization(train_data)

train_data_norm = data_manager.normalize(train_data)

train_labels_norm = data_manager.normalize(train_labels)

test_data_norm = data_manager.normalize(test_data)

# 数据加载器

train_dataset = TensorDataset(train_data_norm, train_labels_norm)

train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True)

# 原始网络结构 + 新损失函数

model = OriginalSVDNetwork(M=64, r=32, hidden_dim=512).to(device)

optimizer = optim.Adam(model.parameters(), lr=1e-3)

scheduler = optim.lr_scheduler.StepLR(optimizer, step_size=50, gamma=0.5)

print(f"模型参数量: {sum(p.numel() for p in model.parameters()):,}")

# 训练50个epoch快速验证

num_epochs = 50

alpha = 0.1 # 降低F正交约束

beta = 0.1 # 降低G正交约束

print(f"正交约束权重: α={alpha}, β={beta}")

for epoch in range(num_epochs):

model.train()

total_loss = 0

total_recon_loss = 0

total_ortho_f_loss = 0

total_ortho_g_loss = 0

for batch_idx, (data, labels) in enumerate(train_loader):

data, labels = data.to(device), labels.to(device)

optimizer.zero_grad()

# 前向传播（训练时F_raw不经过QR）

F_raw, G = model(data)

H_pred = torch.matmul(F_raw, G)

# 新的损失函数

loss, recon_loss, ortho_f_loss, ortho_g_loss = experiment_loss_function(

H_pred, labels, F_raw, G, alpha=alpha, beta=beta

)

loss.backward()

torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)

optimizer.step()

total_loss += loss.item()

total_recon_loss += recon_loss.item()

total_ortho_f_loss += ortho_f_loss.item()

total_ortho_g_loss += ortho_g_loss.item()

scheduler.step()

# 计算平均损失

avg_loss = total_loss / len(train_loader)

avg_recon_loss = total_recon_loss / len(train_loader)

avg_ortho_f_loss = total_ortho_f_loss / len(train_loader)

avg_ortho_g_loss = total_ortho_g_loss / len(train_loader)

# 每5个epoch评估一次

if epoch % 5 == 0:

model.eval()

with torch.no_grad():

test_data_device = test_data_norm.to(device)

F_test, G_test = model(test_data_device)

H_pred_test = torch.matmul(F_test, G_test)

# 反归一化评估

H_pred_denorm = data_manager.denormalize(H_pred_test.cpu())

test_l_ae = calculate_L_AE(H_pred_denorm, test_labels)

print(f'Epoch [{epoch:2d}/{num_epochs}] | '

f'Loss: {avg_loss:.6f} | '

f'Recon: {avg_recon_loss:.6f} | '

f'Ortho_F: {avg_ortho_f_loss:.6f} | '

f'Ortho_G: {avg_ortho_g_loss:.6f} | '

f'L_AE: {test_l_ae:.6f}')

else:

print(f'Epoch [{epoch:2d}/{num_epochs}] | '

f'Loss: {avg_loss:.6f} | '

f'Recon: {avg_recon_loss:.6f} | '

f'Ortho_F: {avg_ortho_f_loss:.6f} | '

f'Ortho_G: {avg_ortho_g_loss:.6f}')

# 保存实验结果

torch.save(model.state_dict(), 'experiment1_model.pth')

# 最终评估

model.eval()

with torch.no_grad():

test_data_device = test_data_norm.to(device)

F_final, G_final = model(test_data_device)

H_pred_final = torch.matmul(F_final, G_final)

H_pred_denorm = data_manager.denormalize(H_pred_final.cpu())

final_l_ae = calculate_L_AE(H_pred_denorm, test_labels)

# 计算MAC

sample_input = test_data_norm[:1]

mega_macs = get_avg_flops(model.cpu(), sample_input.cpu())

score = 100 * final_l_ae + mega_macs

print(f"\n=== 实验1结果 ===")

print(f"L_AE: {final_l_ae:.6f}")

print(f"MACs: {mega_macs:.4f}M")

print(f"Score: {score:.4f}")

return final_l_ae, mega_macs, score

  

if __name__ == "__main__":

run_experiment1()




-------
#!/usr/bin/env python3

"""

实验1：控制变量 - 只改损失函数，保持原网络结构

目标：验证QR分解是否是梯度阻断的根本原因

"""

import numpy as np

import torch

import torch.nn as nn

import torch.optim as optim

from torch.utils.data import DataLoader, TensorDataset

from model_profiler import get_avg_flops

  

class OriginalSVDNetwork(nn.Module):

"""

原始网络结构，但训练时移除QR分解

"""

def __init__(self, M=64, r=32, hidden_dim=512):

super(OriginalSVDNetwork, self).__init__()

self.M = M

self.r = r

# 保持原来的网络结构：简单MLP

input_dim = 2 * M * M # 只用原始矩阵，不加Gram

self.feature_extractor = nn.Sequential(

nn.Linear(input_dim, hidden_dim),

nn.ReLU(),

nn.Linear(hidden_dim, hidden_dim),

nn.ReLU(),

nn.Linear(hidden_dim, hidden_dim),

nn.ReLU()

)

# F矩阵输出头 (64×32)

self.f_head = nn.Linear(hidden_dim, 2 * M * r)

# G矩阵输出头 (32×64)

self.g_head = nn.Linear(hidden_dim, 2 * r * M)

def forward(self, x_complex):

"""

前向传播 - 训练时不做QR，推理时做QR

"""

batch_size = x_complex.shape[0]

# 保持原来的输入处理：只用原始矩阵

x_real = torch.cat([x_complex.real.view(batch_size, -1),

x_complex.imag.view(batch_size, -1)], dim=1)

# 特征提取

features = self.feature_extractor(x_real)

# 生成F矩阵 (64×32)

f_output = self.f_head(features)

f_real = f_output[:, :self.M * self.r].view(batch_size, self.M, self.r)

f_imag = f_output[:, self.M * self.r:].view(batch_size, self.M, self.r)

F_raw = torch.complex(f_real, f_imag)

# 关键改动：训练时不做QR，推理时才做QR

if self.training:

F = F_raw # 训练时使用原始F

else:

F = self.make_orthogonal(F_raw) # 推理时QR正交化

# 生成G矩阵 (32×64)

g_output = self.g_head(features)

g_real = g_output[:, :self.r * self.M].view(batch_size, self.r, self.M)

g_imag = g_output[:, self.r * self.M:].view(batch_size, self.r, self.M)

G = torch.complex(g_real, g_imag)

return F, G

def make_orthogonal(self, F_raw):

"""推理时QR正交化"""

batch_size = F_raw.shape[0]

F_ortho = torch.zeros_like(F_raw)

for i in range(batch_size):

Q, R = torch.linalg.qr(F_raw[i])

F_ortho[i] = Q

return F_ortho

  

class ComplexDataManager:

"""数据管理 - 保持不变"""

def __init__(self):

self.mean_real = 0

self.mean_imag = 0

self.std_real = 1

self.std_imag = 1

def fit_normalization(self, data_complex):

self.mean_real = data_complex.real.mean()

self.mean_imag = data_complex.imag.mean()

self.std_real = data_complex.real.std()

self.std_imag = data_complex.imag.std()

print(f"归一化参数 - 实部: 均值={self.mean_real:.6f}, 标准差={self.std_real:.6f}")

print(f"归一化参数 - 虚部: 均值={self.mean_imag:.6f}, 标准差={self.std_imag:.6f}")

def normalize(self, data_complex):

real_norm = (data_complex.real - self.mean_real) / self.std_real

imag_norm = (data_complex.imag - self.mean_imag) / self.std_imag

return torch.complex(real_norm, imag_norm)

def denormalize(self, data_complex):

real_denorm = data_complex.real * self.std_real + self.mean_real

imag_denorm = data_complex.imag * self.std_imag + self.mean_imag

return torch.complex(real_denorm, imag_denorm)

  

def experiment_loss_function(H_pred, H_true, F_raw, G, alpha=0.1, beta=0.1):

"""

实验损失函数：调低正交约束权重

"""

# 1. 重构损失

recon_loss = torch.mean(torch.abs(H_pred - H_true) ** 2)

# 2. F软正交损失 (权重调低)

batch_size, M, r = F_raw.shape

I = torch.eye(r, dtype=F_raw.dtype, device=F_raw.device).unsqueeze(0).expand(batch_size, -1, -1)

F_gram = torch.matmul(F_raw.conj().transpose(-1, -2), F_raw)

ortho_loss_F = torch.mean(torch.abs(F_gram - I) ** 2)

# 3. G正交损失 (权重调低)

G_gram = torch.matmul(G, G.conj().transpose(-1, -2))

mask = ~torch.eye(r, dtype=torch.bool, device=G.device).unsqueeze(0).expand(batch_size, -1, -1)

off_diagonal = G_gram[mask]

ortho_loss_G = torch.mean(torch.abs(off_diagonal) ** 2)

total_loss = recon_loss + alpha * ortho_loss_F + beta * ortho_loss_G

return total_loss, recon_loss, ortho_loss_F, ortho_loss_G

  

def load_data():

"""加载数据"""

print("=== 加载数据 ===")

train_data = np.load('CompetitionData1/Round1TrainData1.npy')

train_label = np.load('CompetitionData1/Round1TrainLabel1.npy')

test_data = np.load('CompetitionData1/MyTestData.npy')

test_label = np.load('CompetitionData1/MyTestLabel.npy')

print(f"训练数据形状: {train_data.shape}")

# 转换为复数张量

train_complex = torch.complex(

torch.from_numpy(train_data[..., 0]),

torch.from_numpy(train_data[..., 1])

)

train_label_complex = torch.complex(

torch.from_numpy(train_label[..., 0]),

torch.from_numpy(train_label[..., 1])

)

test_complex = torch.complex(

torch.from_numpy(test_data[..., 0]),

torch.from_numpy(test_data[..., 1])

)

test_label_complex = torch.complex(

torch.from_numpy(test_label[..., 0]),

torch.from_numpy(test_label[..., 1])

)

return train_complex, train_label_complex, test_complex, test_label_complex

  

def calculate_L_AE(predictions, targets):

"""计算L_AE"""

diff_norm = torch.norm(predictions - targets, dim=(1, 2))

target_norm = torch.norm(targets, dim=(1, 2))

relative_error = diff_norm / (target_norm + 1e-8)

return relative_error.mean().item()

  

def run_experiment1():

"""运行实验1：只改损失函数"""

print("=== 实验1：只改损失函数，验证QR分解影响 ===")

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

print(f"使用设备: {device}")

# 加载数据

train_data, train_labels, test_data, test_labels = load_data()

# 归一化

data_manager = ComplexDataManager()

data_manager.fit_normalization(train_data)

train_data_norm = data_manager.normalize(train_data)

train_labels_norm = data_manager.normalize(train_labels)

test_data_norm = data_manager.normalize(test_data)

# 数据加载器

train_dataset = TensorDataset(train_data_norm, train_labels_norm)

train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True)

# 原始网络结构 + 新损失函数

model = OriginalSVDNetwork(M=64, r=32, hidden_dim=512).to(device)

optimizer = optim.Adam(model.parameters(), lr=1e-3)

scheduler = optim.lr_scheduler.StepLR(optimizer, step_size=50, gamma=0.5)

print(f"模型参数量: {sum(p.numel() for p in model.parameters()):,}")

# 训练50个epoch快速验证

num_epochs = 50

alpha = 0.1 # 降低F正交约束

beta = 0.1 # 降低G正交约束

print(f"正交约束权重: α={alpha}, β={beta}")

for epoch in range(num_epochs):

model.train()

total_loss = 0

total_recon_loss = 0

total_ortho_f_loss = 0

total_ortho_g_loss = 0

for batch_idx, (data, labels) in enumerate(train_loader):

data, labels = data.to(device), labels.to(device)

optimizer.zero_grad()

# 前向传播（训练时F_raw不经过QR）

F_raw, G = model(data)

H_pred = torch.matmul(F_raw, G)

# 新的损失函数

loss, recon_loss, ortho_f_loss, ortho_g_loss = experiment_loss_function(

H_pred, labels, F_raw, G, alpha=alpha, beta=beta

)

loss.backward()

torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)

optimizer.step()

total_loss += loss.item()

total_recon_loss += recon_loss.item()

total_ortho_f_loss += ortho_f_loss.item()

total_ortho_g_loss += ortho_g_loss.item()

scheduler.step()

# 计算平均损失

avg_loss = total_loss / len(train_loader)

avg_recon_loss = total_recon_loss / len(train_loader)

avg_ortho_f_loss = total_ortho_f_loss / len(train_loader)

avg_ortho_g_loss = total_ortho_g_loss / len(train_loader)

# 每5个epoch评估一次

if epoch % 5 == 0:

model.eval()

with torch.no_grad():

test_data_device = test_data_norm.to(device)

F_test, G_test = model(test_data_device)

H_pred_test = torch.matmul(F_test, G_test)

# 反归一化评估

H_pred_denorm = data_manager.denormalize(H_pred_test.cpu())

test_l_ae = calculate_L_AE(H_pred_denorm, test_labels)

print(f'Epoch [{epoch:2d}/{num_epochs}] | '

f'Loss: {avg_loss:.6f} | '

f'Recon: {avg_recon_loss:.6f} | '

f'Ortho_F: {avg_ortho_f_loss:.6f} | '

f'Ortho_G: {avg_ortho_g_loss:.6f} | '

f'L_AE: {test_l_ae:.6f}')

else:

print(f'Epoch [{epoch:2d}/{num_epochs}] | '

f'Loss: {avg_loss:.6f} | '

f'Recon: {avg_recon_loss:.6f} | '

f'Ortho_F: {avg_ortho_f_loss:.6f} | '

f'Ortho_G: {avg_ortho_g_loss:.6f}')

# 保存实验结果

torch.save(model.state_dict(), 'experiment1_model.pth')

# 最终评估

model.eval()

with torch.no_grad():

test_data_device = test_data_norm.to(device)

F_final, G_final = model(test_data_device)

H_pred_final = torch.matmul(F_final, G_final)

H_pred_denorm = data_manager.denormalize(H_pred_final.cpu())

final_l_ae = calculate_L_AE(H_pred_denorm, test_labels)

# 计算MAC

sample_input = test_data_norm[:1]

mega_macs = get_avg_flops(model.cpu(), sample_input.cpu())

score = 100 * final_l_ae + mega_macs

print(f"\n=== 实验1结果 ===")

print(f"L_AE: {final_l_ae:.6f}")

print(f"MACs: {mega_macs:.4f}M")

print(f"Score: {score:.4f}")

return final_l_ae, mega_macs, score

  

if __name__ == "__main__":

run_experiment1()