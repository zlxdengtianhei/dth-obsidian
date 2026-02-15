  
请你根据上面的计划一个一个完成对照实验，另外请你对/root/huawei-svd-ljz/experiment_opt1_6_fixed_dynamic_rank.py尝试不进行归一化的操作会有什么效果。请你记录训练时的loss等相关数据，完成后创建类似于/root/huawei-svd-ljz/completely_correct_evaluation.py来测试性能，公式一定保持一致，一定要将训练与eval分开来运行，不然可能后有device 冲突。  
  
在每次试验前，请你先确保实验的正确性，可以用更小的epoch来进行测试，然后再进入到30epoch的实验环节。请你注意因为现在epoch较少，所以大一些的loss也是可以接受的，只要趋势向好，证明可行性即可，比较更多是在实验之间进行。  
  
请你用conda activate base来激活环境，注意在所有模型相关文件中都只能使用torch和numpy。注意由于信道矩阵为复数矩阵，所以要支持复数运算

请你用conda activate base来激活环境
--------  
我现在想要实现这样的一个任务，其中数据文件在/CompetitionData,你可以先查看一下都有什么，然后请你完成网络架构的设计，以及训练，eval代码。并且记得对在合适的地方对数据进行归一化。同时请你只用torch和numpy，而不要使用其他任何多余的库。  
  
请你先完成计划，然后逐步完成，记得训练时打印出每个epoch的相关信息，注意在eval时，添加上L_AE,MAC的计算。请你注意代码结构保持简洁，不要太多额外的参数  
  
请你一定要注意，你处理的数据是复数矩阵，在矩阵乘法，以及归一化等等操作时，一定要注意对复数的处理。另外，请你一定使用真实的数据。  
  
请你再回答的时候尽量使用中文  
  
---  
   **Evaluation Metrics**

To comprehensively evaluate both the SVD reconstruction accuracy and orthogonality of singular vectors, we define the **Approximation Error (AE)** as:

$$L_{AE}
= \frac{\lVert H_{\mathrm{label}} - U \Sigma V^H\rVert}
       {\lVert H_{\mathrm{label}}\rVert}
  + \lVert U^H U - I\rVert
  + \lVert V^H V - I\rVert.
$$
Where the $\lVert$ denotes the frobenius norm of a matrix. The average AE across all sampling points in a scenario gives the **overall approximation error** for that scenario. Averaging over all scenarios and all points yields the **final algorithm error**. In addition to the SVD approximation error, the **model complexity** is evaluated using the **number of multiply-accumulate operations (MACs)** during model inference, this can be measured by pytorchs built in profiler.
### 1.1.2        Data Format  
  
This section describes the data file formats provided by the organizing committee and the format for saving the algorithm output results. At the same time, we will provide a set of sample code, including functional modules such as data reading and result storage. Read this section and sample code carefully to ensure that the submitted result format is correct. Otherwise, the evaluation may be invalid due to incorrect file format.  
  
#### 1.1.2.1       Provided data format  
  
●      RoundYCfgDataX.txt: configuration parameter file for the training dataset for scenario X in round Y. The file contains 5 lines. The following table lists the parameters defined in each line.  
  
Table 2: Content of the RoundYCfgDataX.txt File  
  
| | | |  
| ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------- |  
| Parameters | Meaning | Example Value (The actual value is subject to the file.) |  
| $N_{sample}$ | Total number of sampling points in this scenario | 20000 |  
| M | Number of rows in the channel matrix | 64 |  
| N | Number of Channel Matrix Columns | 64 |  
| Q | real and virtual part | 2 |  
| r | The goal is to compute the first r largest singular value. | 32 |  
  
●      RoundYTrainDataX.npy: non-ideal channel training data in the Xth scenario in round Y, which is used as the model training input. The channel data structure is a 4-dimensional complex tensor, and a dimension is $N_{samp} \times M \times r \times Q$. A definition of each dimension is shown in Table 2  
●      RoundYTrainLabelX.npy: ideal channel training label data corresponding to the Xth scenario in the Yth round. The data structure is the same as that of RoundYTrainDataX.npy.  
  
●      RoundYTestDataX.npy: non-ideal channel test data in the Xth scenario in round Y, used as the input for model test. The data structure is the same as that of RoundYTrainDataX.npy (but $N_{sample}$ might be smaller than that of the training data)  
  
#### 1.1.2.2       Submission format  
  
The competing team needs to upload a .zip file which contains the solutions which are named {1-N}.npz, aswell as a python file(extension .py) and the trained weights stored in a .pth file. The content of source file(.py) should contain the code used to both define and train the submitted model. The content of the .pth file should contain the torch.nn.Module.state_dict(), such that it can be loaded with torch.nn.Module.load_state_dict() method. The content of the .npz file should be the following  
  
Table 3: Content of the X.npz File  
  
|                   |                                                                                                      |                                       |     |
| ----------------- | ---------------------------------------------------------------------------------------------------- | ------------------------------------- | --- |
| Keyword parameter | Meaning                                                                                              | Dimension                             |     |
| U                 | Left Singular Matrix Corresponding to Channel Matrix of All Sampling Points                          | $N_{samp} \times M \times r \times Q$ |     |
| S                 | Singular values corresponding to channel matrices at all sampling points, all elements must positive | $N_{samp} \times r$                   |     |
| V                 | Right Singular Matrix Corresponding to Channel Matrix of All Sampling Points                         | $N_{samp} \times M \times r \times Q$ |     |
| C                 | A single float denoting the **Mega MACs** of the model, this can be measured by pytorch profiler     |                                       |     |
  
The submissions for each found should look like the following  
  
| | |  
|---|---|  
|**Competition Stage**|**Result Name**|  
|Round 1|1.npz<br><br>2.npz<br><br>3.npz<br><br><anything>.py<br><br><anything>.pth|  
|Round 2|1.npz<br><br>2.npz<br><br>3.npz<br><br><anything>.py<br><br><anything>.pth|  
  
# 2       Scoring Metrics    

**Evaluation Metrics**

To comprehensively evaluate both the SVD reconstruction accuracy and orthogonality of singular vectors, we define the **Approximation Error (AE)** as:

$$L_{AE}
= \frac{\lVert H_{\mathrm{label}} - U \Sigma V^H\rVert}
       {\lVert H_{\mathrm{label}}\rVert}
  + \lVert U^H U - I\rVert
  + \lVert V^H V - I\rVert.
$$
Where the $\lVert$ denotes the frobenius norm of a matrix. The average AE across all sampling points in a scenario gives the **overall approximation error** for that scenario. Averaging over all scenarios and all points yields the **final algorithm error**. In addition to the SVD approximation error, the **model complexity** is evaluated using the **number of multiply-accumulate operations (MACs)** during model inference, this can be measured by pytorchs built in profiler.
  
The overall score will be calculated as the sum of average $L_{AE}$(Approximation Error) and Mega Macs of the model.   
  
$Score = 100L_{AE} + C$  
  
For instance, if one team gets 0.9856 for the AE, and 1.4177M macs for complexity, then their Score would be 100*0.9856 + 1.4177 = 99.9777.  
  
----  
# 相关文件路径  
  
计算操作数的函数文件：  
model_profiler.py



-----
修改：
Ran tool

Ran tool

Read file: ubpi_lite_svd.py

Read file: ubpi_lite_svd.py

Read file: ubpi_lite_svd.py

Read file: ubpi_lite_svd.py

Read file: ubpi_lite_svd.py

Read file: ubpi_lite_svd.py

Read file: ubpi_lite_svd.py

下面把代码从「数据预处理」到「网络前向与损失」完整梳了一遍，并结合训练日志给出诊断与改进建议。结论先行：

1. 只保留 G=T·Tᴴ 的上三角特征会把与右奇异向量 V 有关的全部信息抛掉，这一步对后续要同时预测 U、V、S 是不足够的。  
2. 网络内部并没有真正用到原始 T 或 G；它先用一个 MLP 生成 U₀、V₀，再凭这些自己拼了一个「假矩阵」T≈U₀DV₀ᴴ（D 固定），随后的双向幂迭代都绕着这张“自我构造”的矩阵打转。这意味着梯度始终在「U₀→T≈→幂迭代→U,V」这个回路里循环，而与真实 T / G 的距离只能靠最外层重构损失去拉 —— 这是造成重构、正交损失都降得慢的核心原因。  
3. Björck 正交化迭代步数虽多，但 step_size 最大只到 0.1，且在 update 里二次裁剪，很难把 ‖UᴴU−I‖ 推到 0 附近；叠加 λ₁=0.2 的高权重，训练过程里 OrthLoss≈6～7 成了总损失的大头，于是网络一直在「拉正交」⇄「保重构」之间拉扯，收敛速度自然慢。  

下面按模块展开。

────────────────────────────────────
一、预处理代码与信息缺失
```57:70:ubpi_lite_svd.py
# 计算 Gram 矩阵 G = T @ T^H
G = T @ T.conj().T
...
feature = np.concatenate([real_parts, imag_parts])  # 4160 维
```
数学上  
 G = U S² Uᴴ，只含 **左奇异向量 U** 和 **奇异值 S²**；  
 H = Tᴴ T = V S² Vᴴ，只含 **右奇异向量 V** 和 **奇异值 S²**。  
因此，仅用 G 的上三角就等于把和 V 相关的所有信息删掉。若网络仍要输出 V，就只能「猜」；这在训练日志里表现为  
• Reconstruction loss≈1.0 附近徘徊（U,S 还能大致对上）  
• Orth loss≈6.5 持平（V 不正交、U 也难被拉正）  

建议  
1. 同时加入 H=TᴴT 的上三角（再多 4160 维），或直接使用 T 的 (Re, Im) 展开（64×64×2=8192 维）。  
2. 如果硬性追求低维，可把 (G,H) 做 PCA/SVD 压缩后再喂网络，但一定要让 V 相关信息存在。

────────────────────────────────────
二、网络前向路径的问题
```360:377:ubpi_lite_svd.py
# 用 U_init、V_init 和固定对角 D 造出 T_approx
D = diag_embed(linspace(1,0.1,L))
T_approx = U_init @ D @ V_initᴴ
```
1. T_approx 与输入特征间只有 **U_init、V_init 两条弱耦合**，与真实 G/T 并无直接联系；  
2. 幂迭代用的始终是这张假 T_approx，奇异值 S 也由 U_init,V_init 自己内循环算出来；  
3. 结果是：网络若想降低真实重构误差，必须同时改动 U_init 与 V_init，但任何对 U_init / V_init 的调整都会先影响「假矩阵」再反向影响 S，导致梯度路径冗长且不稳定。

可行的改法有两条路线：  
A) **把幂迭代挪到输入侧** —— 直接用 (G,H) 做一次特征分解，取 Uₐ,S、Vₐ 的粗估，再让网络去预测精修 ΔU、ΔV、ΔS。这样幂迭代只做一次「物理上成立」的分解，梯度路径清晰。  
B) **砍掉幂迭代** —— 用 MLP / Transformer 直接回归 U,S,V，并在 Loss 端依旧加 Orth & Rec 约束即可，实践里常常更稳定。

────────────────────────────────────
三、OrthLoss 久降不下的技术原因
```401:413:ubpi_lite_svd.py
# 每轮 Björck，step_size ∈ [0.02,0.25] 再多重裁剪
U_current = self.bjorck_ortho(U_new, alpha_clamped)
...
V_current = self.bjorck_ortho(V_new, beta_clamped)
```
• step_size 上限 0.25，再乘以 update 被裁剪后的范数，15 次迭代很难真正把 UᴴU→I；  
• OrthLoss 的梯度被 λ₁=0.2 放大，却又主要来自 Björck，反而拉慢收敛。  

改进方案  
1. 直接用 `torch.linalg.qr` 或 `torch.linalg.svd` 做一次干净的正交化，再微调；  
2. 若继续用 Björck，可把 num_iterations 提到 50+，step_size 固定在 0.5~1 的区间，去掉多重 clamp；  
3. 训练早期把 λ₁ 设小些（0.05），等 Rec loss 稳定后再提高（逐 epoch 提升），能显著加速收敛。

────────────────────────────────────
四、归一化与特征裁剪
预处理后你把所有特征 clip 到 [-5,5]：  
```144:147:ubpi_lite_svd.py
self.features = np.clip(self.features, -5, 5)
```
上三角里的实部在大信号下可轻松 >1e2，直接硬裁掉会丢失对数级差异信息；网络必须学会把「被截平」的特征重新映射回来，浪费容量。  
• 保持 robust scaling + z-score 就已经把长尾压住，clip 到 ±10⁴ 之类即可，没必要 5。  

────────────────────────────────────
五、网络规模与 Dropout
当前模型 1400 万参数，但只有 4160 维特征；再加 0.15～0.10 的多层 Dropout，本质上在做「超大 MLP 推理一个 64×16 的矩阵」，会出现  
• 训练 loss 与验证 loss 几乎同步（过拟合不明显，但也学不到复杂映射）；  
• 梯度在残差块上振荡，幂迭代找不到有效搜索方向。  
建议先把 hidden_dim 收回 256 或 384，Dropout 放到 0.05；或者用 2 层 Transformer Encoder 直接对 128 维 PCA 后的特征做建模，效果通常更好且收敛更快。  

────────────────────────────────────
六、可行的改动组合（推荐先试）
1. 特征 = [上三角(G), 上三角(H)]，input_dim = 8320；  
2. 去掉造 T_approx + 幂迭代，直接回归 U,V,S，其中  
   • 输出 U_raw, V_raw → `torch.linalg.qr` 得 Û,V̂  
   • 输出 S_raw → `softplus` 保正  
   • RecLoss + λ₁*OrthLoss + λ₃*‖S‖₂  
3. hidden_dim=512, 2×Transformer Encoder (8 heads)，总参数 <3 M；  
4. OrthLoss 前 10 epoch λ₁=0.02，之后线性增到 0.2；  
5. 归一化后 **不再 clip 到 ±5**。  

真实项目里，这一套修改通常能把  
• 正交性损失压到 <0.5；  
• 重构相对误差压到 0.05～0.1 之间；  
• 训练速度提升约 2×；  
同时保持较低 FLOPs，更符合“Lite” 目标。  

────────────────────────────────────
七、小结
问题不是单纯出在预处理或网络任一环节，而是「预处理丢信息」+「网络没真正用信息」+「Orth 强约束但优化器到不了」三者叠加。  
先让特征里把 V 信息补回来，再让网络正向路径真正利用这些特征，最后再调 Björck / OrthLoss 权重，你会看到损失曲线明显改善。


Hi! We also encountered the problem of score on the platform is ~10x higher than the one we estimate. Here is our loss function:

def compute_fast_loss_32d(H_true, U, V, S, k_recon=8, epoch=0):
    
    batch_size, M, r_total = U.shape
    
    
    U_k = U[:, :, :k_recon]          
    V_k = V[:, :k_recon, :]         
    S_k = S[:, :k_recon]            
    
    S_diag = torch.diag_embed(S_k).to(U.dtype)
    H_recon = torch.bmm(torch.bmm(U_k, S_diag), V_k)
    
    recon_error = torch.norm(H_true - H_recon, dim=(1,2)) / (torch.norm(H_true, dim=(1,2)) + 1e-8)
    recon_loss = recon_error.mean()
    
    I_r = torch.eye(r_total, device=U.device, dtype=U.real.dtype)
    U_gram = torch.real(torch.bmm(U.conj().transpose(-2,-1), U))
    ortho_U = torch.mean((U_gram - I_r.unsqueeze(0)).pow(2))
    
    V_gram = torch.real(torch.bmm(V, V.conj().transpose(-2,-1)))
    ortho_V = torch.mean((V_gram - I_r.unsqueeze(0)).pow(2))
    
    S_diff = S_k[:, 1:] - S_k[:, :-1]  
    decreasing_loss = torch.mean(F.relu(S_diff))  
    
    S_ortho = S[:, k_recon:]
    small_singular_loss = torch.mean(S_ortho)
    
    ortho_weight = 0.01 if epoch < 15 else 0.05
    small_s_weight = 0.001  
    
    l_ae = recon_loss + ortho_U + ortho_V
    total_loss = (recon_loss + 
                  ortho_weight * (ortho_U + ortho_V) + 
                  0.01 * decreasing_loss + 
                  small_s_weight * small_singular_loss)
    
    return total_loss, l_ae, recon_loss, ortho_U, ortho_V, decreasing_loss, small_singular_loss

Could you please help us with it?