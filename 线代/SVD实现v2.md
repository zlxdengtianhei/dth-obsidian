# 秒解 SVD 的完整实施计划

（仅依赖 **PyTorch + NumPy**，适配 64 × 64 复信道矩阵，保留 32 阶奇异分量）

---

## 1. 数据准备

 预处理流水线（训练 & 推理同用，无需外部常量）  
1. 读取成 `complex64` Tensor

2. **功率归一化**  `H ← H / ‖H‖_F`
3. **公共相位对齐** `φ = angle(mean(H)) ; H ← H·e^{-jφ}`
4. **角域旋转**   `H ← F₆₄ H F₆₄ᴴ`（`F₆₄`=64-pt DFT矩阵）
5. **幅 / 相拆分**  生成三通道：`|H| , cos ∠H , sin ∠H`
6. 训练阶段附加 **1e-3 σ 噪声**；验证/推理不加

输出张量尺寸：`(B, 3, 64, 64)`，在加载线程中完成。

---

## 2. 网络架构

```
Input  : 3×64×64  → flatten(12 288)
Linear : 12 288 → 512      + ReLU
Linear : 512 →  (64+64)L + L  实部
                 (64+64)L + L  虚部    （总 16 448 维）
split  → F_raw (64×32), G_raw (64×32), s_raw (32)
```

• **参数量** ≈ 12 288·512 + 512·16 448 ≈ 6.9 M  
• 所有权重 `float32`；推理可切换 `float16/BF16`。

### 正交化层

在 `forward` 中对 `F_raw , G_raw` 应用 **Björck 迭代两步**，得到  
`F , G` 满足 `FᴴF ≈ I , GᴴG ≈ I`。仅用矩阵乘，不调用额外库。

### 奇异值参数化

`σ = softplus(s_raw.real)` 保证非负常量；推理直接取该值，无需再算。

---

## 3. 损失函数与评估指标

3.1 训练损失

```
ℒ = ‖H  –  G · diag(σ) · Fᴴ‖²_F
```

正交约束已隐式满足，无需额外罚项。

3.2 在线监控  
计算官方 `L_AE` 公式，作为早停与模型选择指标。

---

## 4. 训练细节

|项目|设定|
|---|---|
|Optimizer|Adam, lr = 3 e-4|
|Batch size|64|
|Epochs|200（或验证早停 ±10）|
|LR scheduler|CosineAnnealing, final 1 e-5|
|AMP|`torch.cuda.amp` 开启|
|Gradient clip|‖g‖₂ ≤ 5|
|日志|TensorBoard：loss、AE、σ谱|
|Checkpoint|val `L_AE` 最低者|

预计 1×A100 GPU 训练时间 < 20 min。

---

## 5. 推理流水

```
(1) 预处理 1–4                   # CPU/GPU
(2) forward 一次 MLP            # 约 4 M MAC
(3) Björck 两步 ×2              # 130 k MAC
(4) U = G ,  V = F ,  Σ = diag(σ)
```

总 MAC ≈ **4.1 M / 样本**，内存占用 < 1 MB，单卡吞吐 > 30 k matrices/s。

符号 / 相位本身不影响评分，无需额外后处理。

---

## 6. 验证与 Profiling

1. 用给定公式计算 **平均 `L_AE`**，与基线 SVD (`torch.linalg.svd`) 对比。
2. `torch.profiler` 统计推理 MAC，保证 ≤ 4.5 M。
3. 观察 Σ 谱是否有 > 32 之外的长尾；若是，可考虑小幅升降 `L` 后再训一轮做剪枝。

---



---

●      **Evaluation Metrics**

To comprehensively evaluate both the SVD reconstruction accuracy and orthogonality of singular vectors, we define the **Approximation Error (AE)** as:

$$L_{AE}
= \frac{\lVert H_{\mathrm{label}} - U \Sigma V^H\rVert}
       {\lVert H_{\mathrm{label}}\rVert}
  + \lVert U^H U - I\rVert
  + \lVert V^H V - I\rVert.
$$
Where the $\lVert$ denotes the frobenius norm of a matrix. The average AE across all sampling points in a scenario gives the **overall approximation error** for that scenario. Averaging over all scenarios and all points yields the **final algorithm error**. In addition to the SVD approximation error, the **model complexity** is evaluated using the **number of multiply-accumulate operations (MACs)** during model inference, this can be measured by pytorchs built in profiler.

## 1.1       Data Description

### 1.1.1        Data Overview

We will provide 2 sets of CompetitionData, as shown in Table 1:

●      **CompetitionData:** the official competition datasets and will be provided in stages.

Table 1: Data Overview List

|   |   |   |
|---|---|---|
|Name|Purpose|Remarks|
|CompetitionData1|Used in the first round (to select the top 15). The following documents are provided:<br><br>Configuration File:<br><br>Round1CfgDataX.txt<br><br>Model training file:<br><br>Round1TrainDataX.npy<br><br>Round1TrainLabelX.npy<br><br>Model test file:<br><br>Round1TestDataX.npy|For details about the data format, see section 3.2.2|
|CompetitionData2|Used in the second round (to select the final 6). The following documents are provided:<br><br>Configuration File:<br><br>Round2CfgDataX.txt<br><br>Model training file:<br><br>Round2TrainDataX.npy<br><br>Round2TrainLabelX.npy<br><br>Model test file:<br><br>Round2TestDataX.npy||

### 1.1.2        Data Format

This section describes the data file formats provided by the organizing committee and the format for saving the algorithm output results. At the same time, we will provide a set of sample code, including functional modules such as data reading and result storage. Read this section and sample code carefully to ensure that the submitted result format is correct. Otherwise, the evaluation may be invalid due to incorrect file format.

#### 1.1.2.1       Provided data format

●      RoundYCfgDataX.txt: configuration parameter file for the training dataset for scenario X in round Y. The file contains 5 lines. The following table lists the parameters defined in each line.

Table 2: Content of the RoundYCfgDataX.txt File

|              |                                                            |                                                          |
| ------------ | ---------------------------------------------------------- | -------------------------------------------------------- |
| Parameters   | Meaning                                                    | Example Value (The actual value is subject to the file.) |
| $N_{sample}$ | Total number of sampling points in this scenario           | 20000                                                    |
| M            | Number of rows in the channel matrix                       | 64                                                       |
| N            | Number of Channel Matrix Columns                           | 64                                                       |
| Q            | real and virtual part                                      | 2                                                        |
| r            | The goal is to compute the first r largest singular value. | 32                                                       |

●      RoundYTrainDataX.npy: non-ideal channel training data in the Xth scenario in round Y, which is used as the model training input. The channel data structure is a 4-dimensional complex tensor, and a dimension is $N_{samp} \times M \times r \times Q$. A definition of each dimension is shown in Table 2
●      RoundYTrainLabelX.npy: ideal channel training label data corresponding to the Xth scenario in the Yth round. The data structure is the same as that of RoundYTrainDataX.npy.

●      RoundYTestDataX.npy: non-ideal channel test data in the Xth scenario in round Y, used as the input for model test. The data structure is the same as that of RoundYTrainDataX.npy (but $N_{sample}$ might be smaller than that of the training data)

#### 1.1.2.2       Submission format

The competing team needs to upload a .zip file which contains the solutions which are named {1-N}.npz, aswell as a python file(extension .py) and the trained weights stored in a .pth file. The content of source file(.py) should contain the code used to both define and train the submitted model. The content of the .pth file should contain the torch.nn.Module.state_dict(), such that it can be loaded with torch.nn.Module.load_state_dict() method. The content of the .npz file should be the following

Table 3: Content of the X.npz File

|                   |                                                                                                      |                                       |
| ----------------- | ---------------------------------------------------------------------------------------------------- | ------------------------------------- |
| Keyword parameter | Meaning                                                                                              | Dimension                             |
| U                 | Left Singular Matrix Corresponding to Channel Matrix of All Sampling Points                          | $N_{samp} \times M \times r \times Q$ |
| S                 | Singular values corresponding to channel matrices at all sampling points, all elements must positive | $N_{samp} \times r$                   |
| V                 | Right Singular Matrix Corresponding to Channel Matrix of All Sampling Points                         | $N_{samp} \times M \times r \times Q$ |
| C                 | A single float denoting the **Mega MACs** of the model, this can be measured by pytorch profiler     |                                       |

The submissions for each found should look like the following

|   |   |
|---|---|
|**Competition Stage**|**Result Name**|
|Round 1|1.npz<br><br>2.npz<br><br>3.npz<br><br><anything>.py<br><br><anything>.pth|
|Round 2|1.npz<br><br>2.npz<br><br>3.npz<br><br><anything>.py<br><br><anything>.pth|

# 2       Scoring Metrics   

The overall score will be calculated as the sum of average $L_{AE}$(Approximation Error) and Mega Macs of the model. 

$Score = 100L_{AE} + C$

For instance, if one team gets 0.9856 for the AE, and 1.4177M macs for complexity, then their Score would be 100*0.9856 + 1.4177 = 99.9777.

----
# 相关文件路径
相关数据文件：
\CompetitionData1
计算操作数的函数文件：
model_profiler.py