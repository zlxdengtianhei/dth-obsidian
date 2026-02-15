对于BF16，FP32，对于参数以及优化器状态，最好使用FP32，以及在注意力机制方面的运算使用FP32，BF16更多使用在中间状态，如果需要进行累积的数据最好使用FP32

jaxtyping, einops_einsum可以给每个维度具体给一个名字

对于一个矩阵的计算，FLOPs为:
if torch.cuda.is_available():

B = 16384 # Number of points

D = 32768 # Dimension

K = 8192 # Number of outputs

else:

B = 1024

D = 256

K = 64

device = get_device()

x = torch.ones(B, D, device=device)

w = torch.randn(D, K, device=device)

y = x @ w

We have one multiplication (x\[i]\[j] * w\[j]\[k]) and one addition per (i, j, k) triple.

actual_num_flops = 2 * B * D * K # @inspect actual_num_flops

---
Interpretation:

- B is the number of data points

- (D K) is the number of parameters

- FLOPs for forward pass is 2 (# tokens) (# parameters)

It turns out this generalizes to Transformers (to a first-order approximation).

---
##### MFU
Model FLOPs Utilization
实际的FLOP/s与宣传的比例，一般大于0.5是优秀的

##### FLOPs的计算

重点是对于两个梯度的分解，然后注意dy/dx=w, dy/dw=x, 因为x\*w=y

为了计算 `h2` 中的任意一个元素 `h2[i][k]`，我们需要计算 `sum_j(h1[i][j] * w2[j][k])`。
    - 这个计算涉及 `D` 次乘法和 `D-1` 次加法，约等于 `2 * D` 次 FLOPs。
    - `h2` 矩阵总共有 `B * K` 个元素。

详情看[[FLOPs计算]]

##### 参数初始化
使用Xavier/ Glorot初始化思想，以及截断的正态分布，将其初始化的参数（即使很多）也可以限制方差为1，并且设置\[-3, 3]这样的截断来避免离群值

1. **参数初始化（Parameter Initialization）**：如何正确地创建和初始化神经网络的权重，以确保训练过程的稳定性。
2. **自定义模型构建（Custom Model Building）**：如何使用 `nn.Module` 和 `nn.Parameter` 从零开始构建一个自定义的神经网络结构。
3. **高效数据加载（Efficient Data Loading）**：如何准备数据批次（batch），并利用固定内存（Pinned Memory）和异步传输来优化 CPU 到 GPU 的数据拷贝过程。
4. **随机性与可复现性（Randomness and Reproducibility）**：为什么需要控制实验中的随机性，以及如何通过设置随机种子来确保结果可以复现。

下面，我们将对每个部分进行深入的展开讲解。

---

### 1. `module_parameters`：模块参数详解

这部分的核心是讲解 **神经网络参数的初始化**，以及为什么一个好的初始化策略至关重要。

#### 知识点 1：`nn.Parameter` 是什么？

- 代码中 `w = nn.Parameter(torch.randn(input_dim, output_dim))` 创建了一个 `nn.Parameter` 对象。
- **讲解**：`nn.Parameter` 是 `torch.Tensor` 的一个特殊子类。它与普通 `Tensor` 的最大区别在于：当一个 `nn.Parameter` 对象被赋值为 `nn.Module` 的属性时（例如 `self.weight = nn.Parameter(...)`），它会自动被注册为该模块的参数。
- **意义**：被注册为参数意味着：
    - 它会出现在 `model.parameters()` 的迭代器中。
    - 在训练过程中，优化器（如 `torch.optim.SGD`）会自动找到这些参数并更新它们的梯度。
    - `model.state_dict()` 会包含这些参数，方便模型的保存和加载。
    - 如果是一个普通的 `Tensor`，PyTorch 不会追踪它的梯度，也不会在训练时更新它。

#### 知识点 2：朴素初始化的陷阱

- 代码首先展示了一个简单的随机正态分布初始化：`w = nn.Parameter(torch.randn(input_dim, output_dim))`。
- 然后通过矩阵乘法 `output = x @ w`，发现输出 `output` 的数值尺度（标准差）会随着 `input_dim` 的增大而增大（约为 `sqrt(input_dim)`）。
- **原因分析**：
    - 假设输入 `x` 和权重 `w` 的每个元素都来自标准正态分布（均值为0，方差为1）。
    - `output` 的每个元素 `output_j` 是由 `sum(x_i * w_ij)` for `i` from 1 to `input_dim` 计算得出的。
    - 根据概率论，两个独立随机变量乘积的方差 `Var(X*Y) = Var(X)Var(Y) + Var(X)E[Y]^2 + Var(Y)E[X]^2`。在这里 `E[x_i]=0`, `E[w_ij]=0`, `Var(x_i)=1`, `Var(w_ij)=1`，所以 `Var(x_i * w_ij) = 1`。
    - `output_j` 是 `input_dim` 个这样的独立项的和，所以 `Var(output_j) = input_dim * Var(x_i * w_ij) = input_dim`。
    - 因此，`output_j` 的标准差（衡量数值尺度）就是 `sqrt(input_dim)`。
- **后果**：当 `input_dim` 很大时（如代码中的16384），输出的激活值会非常大。在深度网络中，这种效应会逐层累积，导致激活值爆炸，进而在反向传播时引起 **梯度爆炸（Gradient Explosion）**，使得模型权重更新过大，训练过程极其不稳定甚至失败（出现 `NaN` 值）。

**情景设定：**

- 我们有一个线性层，其计算为 `output = x @ w`。
- 输入 `x` 是一个向量，有 `input_dim` 个元素。我们假设输入数据也经过了标准化，所以 `x` 的每个元素 `x_i` 也是均值为0，方差为1的随机变量。
- 权重 `w` 是一个矩阵，我们只关注它的一列，即计算单个输出神经元 `output_j` 的权重 `w_j`。`w_j` 的每个元素 `w_ij` 也是均值为0，方差为1。

**计算过程：**  
单个输出 `output_j` 的值是这样计算的：  
`output_j = x_1*w_{1j} + x_2*w_{2j} + ... + x_{input_dim}*w_{input_dim,j}`

这是一个**求和**操作，总共加了 `input_dim` 项。

**方差的累积效应：**  
根据概率论的基本性质：

1. 两个独立的、均值为0的随机变量 `A` 和 `B`，它们乘积的方差是 `Var(A*B) = Var(A) * Var(B)`。在这里，`Var(x_i * w_{ij}) = Var(x_i) * Var(w_{ij}) = 1 * 1 = 1`。
2. 一堆独立随机变量之和的方差，等于它们各自方差的和。`Var(A + B) = Var(A) + Var(B)`。

所以，`output_j` 的方差是：  
`Var(output_j) = Var(x_1*w_{1j}) + Var(x_2*w_{2j}) + ... + Var(x_{input_dim}*w_{input_dim,j})`  
`Var(output_j) = 1 + 1 + ... + 1` （总共有 `input_dim` 个 1 相加）  
`Var(output_j) = input_dim`

**结论：**  
输出的**方差**等于输入的维度。而标准差（Standard Deviation），即数值的典型波动范围，是方差的平方根。所以，输出的标准差是 `sqrt(input_dim)`。

#### 朴素策略的灾难性后果

这个 `sqrt(input_dim)` 的缩放因子在深度神经网络中是致命的。

#### 场景一：浅层网络，但输入维度很高

就像代码中的例子，`input_dim = 16384`。  
`sqrt(16384) = 128`。  
这意味着，即使输入和权重的数值都在 `[-1, 1]` 附近，输出的数值也会在 `[-128, 128]` 附近剧烈波动。这些巨大的数值在后续的计算中，尤其是在反向传播计算梯度时，很容易导致**梯度爆炸（Exploding Gradients）**。梯度会变得非常大，使得权重更新的步子迈得过大，直接“跨过”了最优点，导致损失函数振荡或发散，模型无法收敛。

#### 场景二：深度网络

想象一个有10层的深度网络，每层的维度都是512。

- **前向传播**：第一层的输出方差大约是512。这个输出又作为第二层的输入。即使我们做了很好的初始化，第二层的输出方差也会被第一层的巨大方差进一步放大。信号（激活值）逐层被放大，很快就会变成天文数字。这个现象叫做**激活值爆炸**。如果网络中使用了 `sigmoid` 或 `tanh` 等饱和激活函数，这些巨大的输入值会使激活函数输出恒为-1或1，导致其导数几乎为0，从而引发**梯度消失**。
- **反向传播**：梯度在通过链式法则反向传播时，每一层都会乘以该层的权重。如果权重（或激活值）的尺度很大，梯度就会逐层指数级增长，导致**梯度爆炸**。
#### 知识点 3：Xavier/Glorot 初始化思想

- 为了解决上述问题，代码提出了一个修正方案：`w = nn.Parameter(torch.randn(input_dim, output_dim) / np.sqrt(input_dim))`。
- **讲解**：通过将初始化的权重除以 `sqrt(input_dim)`，我们实际上是在缩放权重矩阵的方差。
    - 新的权重 `w'` 的方差 `Var(w'_ij) = Var(w_ij / sqrt(input_dim)) = (1/input_dim) * Var(w_ij) = 1/input_dim`。
    - 现在，输出 `output_j` 的方差变为 `Var(output_j) = input_dim * Var(x_i * w'_ij) = input_dim * (1 * 1/input_dim) = 1`。
- **效果**：通过这种方式，输出的方差被稳定在了 1 左右，不再随输入维度 `input_dim` 的变化而变化。这使得信息（信号）能够在网络中更稳定地前向和反向传播，极大地提高了训练的稳定性。这就是著名的 **Xavier (或 Glorot) 初始化** 的核心思想。

#### 知识点 4：截断正态分布（Truncated Normal Distribution）

- 最后，代码使用了 `nn.init.trunc_normal_`。
- **讲解**：这是一个更安全的实践。标准的正态分布理论上可以产生任意大的值（尽管概率很低）。在初始化时，如果碰巧生成了一个极端的权重值（离群点），它仍然可能对训练初期的稳定性造成负面影响。
- `trunc_normal_` 通过设置 `a` 和 `b` 参数，将采样的值限制在一个区间内（例如，在均值的-3到+3个标准差范围内），从而彻底排除了产生极端初始值的可能性，让初始化过程更加稳健。

---

### 2. `custom_model`：自定义模型

这部分展示了如何利用 `nn.Module` 和前面定义的 `Linear` 层来构建一个更复杂的、多层次的自定义模型。

#### 知识点 1：`nn.Module` 和 `nn.ModuleList`

- `Cruncher` 类继承自 `nn.Module`，这是所有 PyTorch 模型的基类。
- 在 `__init__` 方法中，它使用 `nn.ModuleList` 来存储一系列的 `Linear` 层。
- **讲解**：为什么不用普通的 Python 列表 `[]`？
    - 如果你使用 `self.layers = [Linear(d, d), Linear(d, d)]`，PyTorch 将无法自动发现这些 `Linear` 子模块。它们的参数不会被注册到 `Cruncher` 模型中，`model.parameters()` 也找不到它们。
    - `nn.ModuleList` 就像一个对 `nn.Module` 友好的列表。它能正确地将其包含的所有子模块注册到父模块中，确保所有参数都能被正确追踪和管理。

#### 知识点 2：模型的前向传播 (`forward` 方法)

- `forward` 方法定义了数据如何流经模型。
- **流程解析**：
    1. 输入 `x` 的尺寸是 `[B, D]` (批量大小, 特征维度)。
    2. 通过一个 `for` 循环，`x` 依次通过 `self.layers` 中的每一个 `Linear` 层。
    3. 然后，`x` 通过最后的 `self.final` 层，这个层将维度从 `D` 压缩到 `1`。此时 `x` 的尺寸变为 `[B, 1]`。
    4. `x.squeeze(-1)` 操作移除了最后一个维度（因为它的size是1），将张量从 `[B, 1]` 变为 `[B]`。这通常是为了方便与一个一维的目标标签 `y` (尺寸为 `[B]`) 计算损失函数（如均方误差损失）。

#### 知识点 3：模型的使用和设备转移

- 代码演示了如何实例化模型、检查参数数量，并将模型和数据移动到 GPU。
- `device = get_device()` 和 `model = model.to(device)` 是 PyTorch 中将模型（包括其所有参数）移动到指定设备（如 'cuda:0' 或 'cpu'）的标准做法。
- 同样，输入数据 `x` 也需要通过 `x = torch.randn(..., device=device)` 或 `x = x.to(device)` 移动到与模型相同的设备上，否则会报错。这是在 GPU 上进行计算的必要步骤。

---

### 3. `get_batch`：获取数据批次

这部分关注的是数据预处理流程中的一个关键环节：如何高效地从数据集中采样一个批次并将其提供给 GPU。

#### 知识点 1：批次采样（Batch Sampling）

- `torch.randint(len(data) - sequence_length, (batch_size,))` 从整个数据集中随机选择 `batch_size` 个起始点。
- **讲解**：这是实现 **随机梯度下降 (SGD)** 的基础。通过在每个训练步骤中随机采样数据，模型可以避免因数据顺序而产生的偏见，有助于跳出局部最优解，从而获得更好的泛化能力。

#### 知识点 2：固定内存（Pinned Memory）与异步数据传输

这是该函数中最具技术含量、也是最重要的优化技巧。

- **背景**：默认情况下，CPU 上的 `torch.Tensor` 存储在 **可分页内存 (Paged Memory)** 中。操作系统可以自由地将这些内存页面移动到物理内存的其他位置，或者交换到磁盘上。
    
- **问题**：当从 CPU 向 GPU 传输数据时，GPU 的硬件（通过 DMA，直接内存访问）只能从 **不可分页（或称“固定”）内存 (Pinned/Page-locked Memory)** 中直接读取数据。如果你的数据在可分页内存中，数据传输会经历两个步骤：
    
    1. CPU 隐式地将数据从可分页内存复制到一个临时的、固定的“中转站”内存区域。
    2. GPU 从这个中转站将数据复制到自己的显存中。  
        这个过程是 **同步的**，意味着 CPU 必须等待这个两步复制操作全部完成后才能继续做其他事情。
- **解决方案与优势**：
    
    1. `x = x.pin_memory()`：这个调用明确地告诉操作系统：“不要移动这块内存，把它‘钉’在物理内存的当前位置”。这样，`x` 就位于固定内存中了。
    2. `x = x.to(device, non_blocking=True)`：当数据已经被固定后，我们可以使用 `non_blocking=True`（异步）模式进行传输。
        - 这个调用会立即返回，CPU 不会等待数据传输完成。它会告诉 GPU：“嘿，开始把这份在固定内存里的数据拷走吧”，然后 CPU 就立刻解放出来，可以去执行下一行代码了。
- **最终效果**：如注释中所述，这允许我们实现 **计算与数据传输的重叠（Overlap）**。在一个典型的训练循环中，流程可以优化为：
    
    - **第 N 步**：CPU 将第 N 批数据 `batch_N` (已固定) **异步**传输到 GPU。
    - **同时**：GPU 正在使用第 N-1 批数据 `batch_(N-1)` 进行前向和反向传播计算。
    - **同时**：CPU 在发起 `batch_N` 的传输后，可以立即开始从磁盘读取、预处理并固定 **第 N+1 批** 数据 `batch_(N+1)`。

通过这种方式，数据传输的延迟被隐藏在了 GPU 的计算时间之下，从而显著提高了 GPU 的利用率和整体的训练吞吐量。

---

### 4. `note_about_randomness`：关于随机性的说明

这部分强调了在机器学习实验中控制随机性以确保 **可复现性（Reproducibility）** 的重要性。

#### 知识点 1：随机性的来源

- 在训练神经网络时，随机性无处不在，主要来源包括：
    - **参数初始化**：如 `torch.randn`。
    - **正则化方法**：如 Dropout，它在训练时会随机丢弃神经元。
    - **数据处理**：如数据增强时的随机翻转、裁剪，以及数据加载时对样本的随机打乱和采样。

#### 知识点 2：为什么需要可复现性？

- **调试（Debugging）**：如果你的代码因为某个随机事件而偶尔出错，定位问题会变得极其困难。固定随机种子后，错误会稳定复现，便于追踪和修复。
- **公平比较（Fair Comparison）**：当你尝试改进模型或调整超参数时，你需要确保性能的提升是源于你的改动，而不是因为一次“幸运”的随机初始化。
- **科学研究与合作（Scientific Research & Collaboration）**：发表的论文或与他人分享的代码，如果结果无法复现，其可信度会大打折扣。

#### 知识点 3：如何设置随机种子

- 为了完全控制随机性，你需要为你代码中用到的所有产生随机数的库都设置种子。
- `torch.manual_seed(seed)`：控制 PyTorch 在 CPU 上的随机数生成器。对于 GPU，通常还需要 `torch.cuda.manual_seed(seed)` 或 `torch.cuda.manual_seed_all(seed)`。
- `import numpy as np; np.random.seed(seed)`：如果你的数据预处理（例如，使用 NumPy 进行的某些操作）中包含随机性，则需要设置 NumPy 的种子。
- `import random; random.seed(seed)`：如果你的代码使用了 Python 内置的 `random` 模块（例如，随机打乱一个文件列表），也需要设置它的种子。

将这三者（或更多，取决于你用的库）在程序开始时一起设置，是保证实验可复现性的标准做法。

---
##### Dataload
memmap可以按需取用数据

----

### Optimizer
- momentum = SGD + exponential averaging of grad

- AdaGrad = SGD + averaging by grad^2

- RMSProp = AdaGrad + exponentially averaging of grad^2

- Adam = RMSProp + momentum

AdaGrad:  [https://www.jmlr.org/papers/volume12/duchi11a/duchi11a.pdf](https://www.jmlr.org/papers/volume12/duchi11a/duchi11a.pdf)

optimizer = AdaGrad(model.parameters(), lr=0.01)

state = model.state_dict() # @inspect state

Compute gradients

x = torch.randn(B, D, device=get_device())

y = torch.tensor([4., 5.], device=get_device())

pred_y = model(x)

loss = F.mse_loss(input=pred_y, target=y)

loss.backward()

Take a step

optimizer.step()

state = model.state_dict() # @inspect state

Free up the memory (optional)

optimizer.zero_grad(set_to_none=True)

代码详解：[[优化器代码详解]]

----
#### checkpointing
保存模型和优化器

def checkpointing():

Training language models take a long time and certainly will certainly crash.

You don't want to lose all your progress.

During training, it is useful to periodically save your model and optimizer state to disk.

model = Cruncher(dim=64, num_layers=3).to(get_device())

optimizer = AdaGrad(model.parameters(), lr=0.01)

Save the checkpoint:

checkpoint = {

"model": model.state_dict(),

"optimizer": optimizer.state_dict(),

}

torch.save(checkpoint, "model_checkpoint.pt")

Load the checkpoint:

loaded_checkpoint = torch.load("model_checkpoint.pt")

---
#### Memory
# Parameters

num_parameters = (D * D * num_layers) + D # @inspect num_parameters

assert num_parameters == get_num_parameters(model)

# Activations

num_activations = B * D * num_layers # @inspect num_activations

# Gradients

num_gradients = num_parameters # @inspect num_gradients

# Optimizer states

num_optimizer_states = num_parameters # @inspect num_optimizer_states

# Putting it all together, assuming float32

total_memory = 4 * (num_parameters + num_activations + num_gradients + num_optimizer_states) # @inspect total_memory


参数相关详解：[[Memory Use 详解]]