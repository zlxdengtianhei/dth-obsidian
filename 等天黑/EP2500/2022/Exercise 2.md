这是一份非常经典的**网络安全（Network Security）**与**安全路由（Secure Routing）**的综合练习题。它涵盖了密码学应用（公钥/对称密钥）、密钥分发、图论（路径不相交）、概率论（几何分布在丢包重传中的应用）以及纠删码/冗余传输策略。

以下是逐段的中英对照翻译，以及对每道题目核心考点和潜在“坑（Pitfalls）”的详细解析。

---

### Context / 背景描述

**原文：**
> **Exercise 2 Secure Data Transmission (100 points + 30 extra credit)**
> Consider the network topology in Fig. 2: Alice needs to communicate securely and reliably with Bob in the presence of adversaries that can disrupt the data communication. Here, let node E be the adversary.
> Alice (and Bob) obtained from the underlying routing (route discovery) protocol three alternative paths, marked with red, green, and blue arrows. Without loss of generality, please assume that Alice and Bob have certificates issued by a certification authority (CA).

**翻译：**
> **练习 2：安全数据传输（100分 + 30分 额外加分）**
> 考虑图 2 中的网络拓扑：Alice 需要在存在可能破坏数据通信的对手的情况下，与 Bob 进行安全可靠的通信。这里，设节点 E 为对手。
> Alice（和 Bob）通过底层路由（路由发现）协议获得了三条备选路径，分别用红色、绿色和蓝色箭头标出。不失一般性地，请假设 Alice 和 Bob 拥有由证书颁发机构（CA）签发的证书。

**💡 题目分析：**
*   **设定：** 这是一个典型的中间人（Adversary E）场景。
*   **资源：** 拥有CA证书意味着双方知道对方的 **公钥（Public Key）** 且由于证书的存在，这些公钥是可信的，不用担心公钥替换攻击。
*   **路径：** 虽然你看不到图，但文字描述暗示了：
    *   红、绿、蓝三条路径。
    *   **E 在红色路径上**（通常也是习题的惯例，且下文Q3证实了这一点）。
    *   蓝色路径在Q1中被假设为安全的。

---

### Question 1: Cryptography & Key Transport

**原文：**
> 1. (15 pt) Alice wishes to send authenticated and confidential messages, each message being, for example, 100KB, to Bob. Is it efficient for Alice and Bob to secure their message transmissions using public key cryptography? If not, explain briefly why and sketch a key transport protocol, i.e., a protocol that allows Alice to provide a symmetric key for Alice and Bob to use and secure their communication (ensuring authenticity, integrity, freshness and confidentiality). You can assume they execute the key transport protocol over the blue path, i.e., they are not disrupted by E; Alice needs to have confirmation that Bob received the key and it is the only entity in the system to have it. Please provide the protocols (key transport and secure message transmission using the transported symmetric key over a single path) and explain briefly why they satisfy the sought properties.

**翻译：**
> 1. (15 分) Alice 希望向 Bob 发送经过认证且保密的消息，例如每条消息大小为 100KB。Alice 和 Bob 使用公钥加密技术来直接保护他们的消息传输是否高效？如果不是，请简要解释原因，并草拟一个密钥传输协议（Key Transport Protocol），即允许 Alice 提供一个对称密钥供她和 Bob 使用，以保护他们的通信（确保真实性、完整性、新鲜度和机密性）。你可以假设他们在蓝色路径上执行密钥传输协议，即不受 E 的干扰；Alice 需要确认 Bob 收到了密钥，并且 Bob 是系统中唯一拥有该密钥的实体。请提供协议（密钥传输协议以及使用传输后的对称密钥在单条路径上进行的安全消息传输协议），并简要解释它们为何满足所需的属性。

**🚧 这一题的“坑”与考点：**

1.  **公钥加密的低效性（Efficiency）：**
    *   **坑：** 如果你回答“是”，这题就丢分了。
    *   **正解：** 公钥加密（如RSA）计算量大，速度慢，通常比对称加密（如AES）慢3-4个数量级。对于 100KB 这种较大数据，直接用公钥加密非常低效。标准做法是**混合加密（Hybrid Encryption）**。

2.  **密钥传输 vs 密钥交换：**
    *   **坑：** 题目问的是 **Key Transport**（Alice 生成发给 Bob），而不是 Diffie-Hellman Key Exchange（双方协商）。不要写错协议类型。
    *   **要求：** Alice 生成对称密钥 $K$，用 Bob 的公钥加密传给 Bob，且需要用 Alice 的私钥签名（保证 Authenticity）。

3.  **新鲜度（Freshness）：**
    *   **坑：** 容易忘记防止**重放攻击**。
    *   **解法：** 协议中必须包含 **Nonce（随机数）** 或 **时间戳**。

4.  **确认机制（Confirmation）：**
    *   **坑：** 题目明确要求 Alice 知道 Bob 收到了。
    *   **解法：** 仅仅发送是不够的，Bob 必须发回一个 ACK，且这个 ACK 最好是用新交换的密钥 $K$ 加密的（作为 Key Confirmation）。

5.  **后续的数据传输协议：**
    *   不要只写密钥怎么传，还要写拿到密钥 $K$ 后，数据 $M$ 怎么传。通常是 `Encrypt_K(M || MAC_K(M))` 或者 GCM 模式。

---

### Question 2: Topology & Disjointness

**原文：**
> 2. (10 pt) Looking at the three available paths, are they node- or edge- disjoint and why? Which type is preferable in the presence of an adversary? For this topology, how many nodes would need to be adversarial so that Alice and Bob cannot communicate securely?

**翻译：**
> 2. (10 分) 观察这三条可用路径，它们是节点不相交（Node-disjoint）还是边不相交（Edge-disjoint）？为什么？在存在对手的情况下，哪种类型更优？对于此拓扑，需要多少个节点变为恶意节点，才能导致 Alice 和 Bob 无法进行安全通信？

**🚧 这一题的“坑”与考点：**

1.  **节点不相交 vs 边不相交：**
    *   **概念：** **边不相交**指路径间没有公共边；**节点不相交**指路径间没有公共节点（除源和宿）。
    *   **坑：** 节点不相交必然蕴含边不相交，但反之不然。
    *   **优劣：** **节点不相交更优**。因为如果一个节点被攻陷，那么连接该节点的所有边都不安全。如果是仅仅边不相交（共用了一个中间节点），攻击者拿下那个共用节点，就切断了所有经过它的路径。

2.  **所需的攻击者数量：**
    *   **逻辑：** 基于**最小割（Min-Cut）**原理。如果有 3 条节点不相交的路径，攻击者必须至少攻陷 3 个节点（每条路径上各一个）或 3 条链路才能完全阻断通信。

---

### Question 3: Detection Logic

**原文：**
> 3. (15 pt) Let Alice be oblivious and randomly select one of the three paths for each message to send, with probability 1/3. When transmitting over the red path, the message is either tampered or dropped by E. How can Alice detect either case? Please augment the protocol from question 1 with notations in Table 1 and explain your solution.

**翻译：**
> 3. (15 分) 假设 Alice 是“盲目”的，每条发送的消息都以 1/3 的概率随机选择三条路径中的一条。当在红色路径传输出时，消息会被 E 篡改或丢弃。Alice 如何检测这两种情况？请使用表 1 中的符号（注：需在答案中自行定义或参考讲义标准符号）扩充问题 1 中的协议，并解释你的方案。

**🚧 这一题的“坑”与考点：**

1.  **篡改 vs 丢弃的检测机制不同：**
    *   **篡改（Tampering）：** 靠 **MAC（消息认证码）** 或 **数字签名** 检测。Alice 发送时附带 MAC，Bob 解密检查 MAC，如果不匹配则丢弃。
    *   **丢弃（Dropping）：** 靠 **ACK（确认字符）** 和 **超时重传（Timeout）** 检测。如果 Alice 发出消息后，在规定时间内没收到 Bob 的 ACK，则视为丢失。

2.  **反馈回路：**
    *   **坑：** Alice 怎么知道发生了篡改？
    *   **逻辑：** 通常 Bob 如果检测到篡改，他可以选择静默（由 Alice 超时判断出错），或者发送一个 NACK（否定应答）。但最简单的机制是：**Alice 依赖 ACK。无论是篡改（Bob 拒收，不发 ACK）还是丢弃（Bob 没收到），Alice 最终看到的现象都是“超时未收到 ACK”。**

---

### Question 4: Probability & Delay

**原文：**
> 4. (20 pt) Assume that each transmission attempt (successfully concluding or detecting the tampering/loss) across one of the randomly chosen paths, with probability 1/3, lasts $\tau$ seconds. If tempering/loss is detected, the same message is retransmitted with the same protocol (randomly select one of the three paths for each message to send, with probability 1/3). For simplicity, let us assume this is the only reason for packet loss (i.e., no other network impairments) other than the attacker actions.
> • If Alice has 10 messages to transmit and E drops/tampers with all messages (or retransmissions) over the red path, i.e., $p_{attack} = 1$, what will be the average delay to complete the transmission?
> • What if the probability to have a packet tampered/dropped by E is $p_{attack} = 0.5$?
> Please write down any equations or formulas that you used to derive your answers.

**翻译：**
> 4. (20 分) 假设每次在随机选择的一条路径（概率 1/3）上的传输尝试（成功完成或检测到篡改/丢失），持续 $\tau$ 秒。如果检测到篡改/丢失，同一消息将使用相同的协议重传（以 1/3 的概率随机选择三条路径中的一条）。为简单起见，假设除了攻击者的行为外，这是数据包丢失的唯一原因。
> • 如果 Alice 有 10 条消息要传输，且 E 丢弃/篡改红色路径上的所有消息（或重传消息），即 $p_{attack} = 1$，那么完成传输的平均延迟是多少？
> • 如果 E 篡改/丢弃数据包的概率是 $p_{attack} = 0.5$，结果又是多少？
> 请写出你用于推导答案的任何方程或公式。

**🚧 这一题的“坑”与考点：**

1.  **几何分布（Geometric Distribution）：**
    *   这是一个典型的重传问题。直到成功的尝试次数 $X$ 服从几何分布。
    *   期望尝试次数 $E[X] = 1 / p_{success}$。

2.  **计算成功概率 $p_{success}$：**
    *   **情况 1 ($p_{attack} = 1$)：**
        *   路径 1 (红): 选它概率 1/3 -> 必败。
        *   路径 2 (绿): 选它概率 1/3 -> 成功。
        *   路径 3 (蓝): 选它概率 1/3 -> 成功。
        *   总成功率 $P_s = 1/3 \times 0 + 1/3 \times 1 + 1/3 \times 1 = 2/3$。
    *   **情况 2 ($p_{attack} = 0.5$)：**
        *   路径 1 (红): 选它 1/3，但通过率 0.5。即 $1/3 \times 0.5 = 1/6$ 成功。
        *   其他路径: $2/3$ 成功。
        *   总成功率 $P_s = 1/6 + 2/3 = 5/6$。

3.  **平均延迟计算：**
    *   单条消息平均尝试次数 = $1/P_s$。
    *   单条消息平均时间 = $(1/P_s) \times \tau$。
    *   10 条消息总时间 = $10 \times (1/P_s) \times \tau$。
    *   **坑：** 别把 $\tau$ 漏了，也别忘了乘以 10。

---

### Question 5: Intelligent Detection (Rating Mechanism)

**原文：**
> 5. (20 pt) Alice can apparently be more intelligent in detecting which path is controlled by the attacker. This can be done with the help of a rating mechanism for each path: if k successive packets over any path are dropped or tampered with, the path is no longer used. ...
> How fast will Alice detect the presence of E if the adversary drops a packet with probability $p_{attack} = 0.5$ and $k=1$? I.e., after how many packet transmissions over this path on the average?
> How fast will the path with E be discarded if $k=2$ on the average?
> ... (Hints: Let $A_1$ be the average number of packet transmissions before the first drop by E...)

**翻译：**
> 5. (20 分) Alice 显然可以更智能地检测哪条路径被攻击者控制。这可以通过对每条路径的评级机制来实现：如果某条路径上连续 $k$ 个数据包被丢弃或篡改，则不再使用该路径。 ...
> 如果攻击者以 $p_{attack} = 0.5$ 的概率丢弃数据包且 $k=1$，Alice 多快能检测到 E 的存在？即，平均在该路径上传输多少个数据包后？
> 如果 $k=2$，平均多快会丢弃有 E 的路径？
> ... (提示：设 $A_1$ 为 E 第一次丢包前的平均传输次数...)

**🚧 这一题的“坑”与考点：**

1.  **仅考虑特定路径：** 题目问的是 "transmissions over **this** path"（在这条路径上），所以计算时不用管路径选择的 1/3 概率，只关注红色路径本身的统计特性。

2.  **$k=1$ 的情况：**
    *   这很简单，就是等待第一次失败。几何分布，成功概率（这里指触发检测的概率，即丢包）是 $p = 0.5$。
    *   期望 = $1/0.5 = 2$ 次传输。

3.  **$k=2$ 的情况（必须连续失败）：**
    *   **巨坑：** 只有 **连续（Successive/Consecutive）** 两次失败才算检测到。如果“失败-成功-失败”，计数器会重置。
    *   **状态机分析（Hint 的意思）：**
        *   设 $E$ 为需要的平均步数。
        *   第一步：
            *   50% 概率成功（没丢）：浪费了 1 步，一切重头开始（状态回到 0）。贡献：$0.5 \times (1 + E)$。
            *   50% 概率失败（丢了）：耗费 1 步，进入“已失败1次”的状态。
        *   从“已失败1次”的状态往下走：
            *   50% 概率成功：前功尽弃，浪费了这 1 步，回到起点。贡献：$0.5 \times (1 + E)$。
            *   50% 概率失败：再耗费 1 步，达成 $k=2$，结束。
    *   你需要根据这个递归逻辑（或者 Hint 中的 $A_1, A_2$ 定义）列出方程组求解。

---

### Question 6: Intelligent Adversary (Extra Credit)

**原文：**
> 6. (extra credit 15 pt) Consider the same setting as that in question 5. What if E is intelligent, i.e., it does not drop or tamper packets randomly and knows the path rating mechanism and the value of k, say, $k=2$? What is the worst-case damage E can cause to the communication across this path? What is the worst-case damage E can cause given any k value ($k>2$)?

**翻译：**
> 6. (额外加分 15 分) 考虑与问题 5 相同的设置。如果 E 是智能的，即它不随机丢弃或篡改数据包，并且知道路径评级机制和 $k$ 的值（例如 $k=2$），会发生什么？E 能对通过该路径的通信造成的**最坏情况损害（Worst-case damage）**是什么？对于任意 $k$ 值 ($k>2$)，E 能造成的最坏情况损害是什么？

**🚧 这一题的“坑”与考点：**

1.  **博弈论思维：** 攻击者的目标是 **最大化破坏（丢包）** 同时 **避免被检测（不触发连续 k 次丢包）**。
2.  **最优策略：** 攻击者会在连续丢弃 $k-1$ 个包后，故意放行 1 个包。这样计数器重置，路径永远不会被封禁。
3.  **量化损害：**
    *   每 $k$ 次传输中，丢弃 $k-1$ 次，成功 1 次。
    *   **丢包率（Loss Rate）：** $(k-1)/k$。
    *   **吞吐量（Throughput）：** 降为 $1/k$。
    *   当 $k$ 很大时，攻击者几乎可以阻断该路径而永远不被发现。

---

### Question 7: Fragmentation & Redundancy

**原文：**
> 7. (20 pt) Now consider Alice using a different strategy: for each message, $m_i$, she splits it in 3 pieces, $m_i^1, m_i^2, m_i^3$, adds some redundancy so that any two out of three pieces of $m_i$ suffice for Bob to reconstruct the message. The three pieces are transmitted across the three disjoint paths and cryptographically protected... Can tampering/dropping of any of the pieces cause damage to the transmission and/or be detected? Describe briefly how. What will be average delay to complete the transmission of 10 messages if E drops/tampers with all messages (or retransmissions) over the red path, i.e., $p_{attack} = 1$?

**翻译：**
> 7. (20 分) 现在考虑 Alice 使用不同的策略：对于每条消息 $m_i$，她将其分成 3 个片段 $m_i^1, m_i^2, m_i^3$，并添加冗余，使得 $m_i$ 的任意三个片段中的两个足以让 Bob 重构消息。这三个片段通过三条不相交的路径传输并受到加密保护... 任何片段的篡改/丢弃是否会对传输造成损害和/或被检测到？简要描述如何检测。如果 E 丢弃/篡改红色路径上的所有消息（或重传消息），即 $p_{attack} = 1$，完成 10 条消息传输的平均延迟是多少？

**🚧 这一题的“坑”与考点：**

1.  **纠删码/门限方案（Erasure Coding / Threshold Scheme）：** 这是一个 (2,3) 方案。只要收到 2 个就能恢复。
2.  **损害分析：**
    *   因为有 3 条路径，坏人只在红色路径。如果红色路径丢包/被篡改，Bob 依然能收到 绿色 和 蓝色 路径的包。
    *   **关键点：** 因为 2 个好包就够了，所以**不需要重传**。
3.  **检测：**
    *   **完整性：** 每个分片都有 MAC。如果红色分片被篡改，MAC 验证失败，Bob 直接丢弃该分片，使用另外两个。
4.  **延迟计算：**
    *   **坑：** 这里的延迟不再受概率影响。因为红色路径即使 100% 丢包，Bob 每次都能靠绿+蓝恢复消息。
    *   **结果：** 每次传输只要 1 个 $\tau$（假设三条路径并发，取最大值，且题目没说路径间有延迟差异）。总延迟 = $10 \tau$。这比 Q4 快得多。

---

### Question 8: Strategy Comparison (Extra Credit)

**原文：**
> 8. (extra credit 15 pt) What is the advantage of Alice’s strategy in question 7 compared to her strategy in question 4? Is there a disadvantage? If so, can you please quantify the latter, stating clearly assumptions needed?

**翻译：**
> 8. (额外加分 15 分) 问题 7 中 Alice 的策略与问题 4 中的策略相比有什么优势？有劣势吗？如果有，请量化后者，并清楚地说明所需的假设。

**🚧 这一题的“坑”与考点：**

1.  **优势（Advantage）：**
    *   **低延迟：** 不需要重传（在只有 1 条坏路的情况下）。Q7 是确定性的延迟，Q4 是概率性的延迟。
    *   **抗干扰性：** 鲁棒性更强。

2.  **劣势（Disadvantage）：**
    *   主要是 **通信开销（Bandwidth Overhead）**。
    *   **量化：**
        *   Q4 策略：每次发 1 个完整消息 $S$。如果只有 1/3 概率选到坏路，平均发送量可能并不大（取决于 $p_{attack}$）。
        *   Q7 策略：本来发 $S$ 大小的消息，现在变成了发 3 个片段。为了实现“3取2”，通常每个片段的大小是原消息的 $1/2$（例如 Parity RAID 逻辑）。
        *   **总量：** $3 \times (0.5 S) = 1.5 S$。
        *   **结论：** 每次传输消耗的带宽增加了 50%。如果网络拥塞是瓶颈，这可能是个问题。

希望这份详细的分析能帮到你！如果你需要具体的数学计算步骤（比如 Q5 的递归方程解法），请告诉我。


这是一个非常严谨且具有深度的网络安全与协议设计练习。为了确保你能够拿到高分（甚至满分），我将采用**批判性思维（Critical Thinking）**的方式，不仅给出标准解题思路，还会指出题目中可能隐藏的**陷阱（Pitfalls/Gotchas）**、需要明确的**假设（Assumptions）**以及在真实世界工程实现与理论模型之间的差距。

以下是针对每一道题的深度解析与解答策略：

---

### Q1: 密码学与密钥传输协议 (Cryptography & Key Transport)

**核心任务：** 判断公钥加密是否高效，并设计一个安全的密钥传输协议。

**批判性解析：**
1.  **效率陷阱（Efficiency）：**
    *   **标准回答：** 直接使用公钥加密（如 RSA）传输 100KB 大消息是**极低效**的（计算开销大）。
    *   **正确方案：** 使用**混合加密体制（Hybrid Encryption）**。即：利用公钥加密传输短小的“对称会话密钥（Session Key, $K_s$）”，然后利用 $K_s$（如 AES-256）加密那 100KB 的数据。
2.  **协议设计的完整性（Security Properties）：**
    *   **题目要求：** 真实性（Authenticity）、完整性（Integrity）、新鲜度（Freshness）、机密性（Confidentiality）、唯一性（Only entity to have it）、确认（Confirmation）。
    *   **常见错误（Fatal Flaws）：**
        *   **忘记签名：** 很多学生只用 Bob 的公钥加密 $K_s$ 发给 Bob ($E_{Pub_B}(K_s)$)。这保证了机密性，但**没有保证真实性（Authenticity）**。任何路人甲都可以冒充 Alice 给 Bob 发个密钥。必须加上 Alice 的私钥签名。
        *   **忘记防重放：** 必须包含 **Nonce（随机数）** 或 **时间戳（Timestamp）** 来保证新鲜度。
        *   **忘记确认（Confirmation）：** 题目明确要求“Alice needs to have confirmation”。这意味着 Bob 收到密钥后，必须发回一个 ACK，且这个 ACK 最好是用新密钥 $K_s$ 加密或认证过的，以证明 Bob 确实解开了密钥（Key Confirmation）。

**推荐协议草案（Notations）：**
*   $A, B$: Alice, Bob
*   $K_s$: 对称会话密钥
*   $N_A$: Alice 生成的 Nonce (用于防重放)
*   $Sig_A$: Alice 的签名
*   $E_{Pub_B}$: 用 Bob 公钥加密
*   $MAC_{K_s}$: 消息认证码

**流程：**
1.  **Key Transport (Blue Path):**
    *   $A \rightarrow B: E_{Pub_B}(K_s, A, N_A) \ || \ Sig_A(Hash(E_{Pub_B}(K_s, A, N_A)))$
    *   *解释：* 加密保证机密性；签名保证真实性和完整性；Nonce保证新鲜度。
    *   $B \rightarrow A: MAC_{K_s}(N_A + 1)$
    *   *解释：* Bob 用解出的 $K_s$ 对 Nonce 变换后做 MAC，证明他收到了且解密成功（Key Confirmation）。
2.  **Secure Transmission (Single Path):**
    *   $A \rightarrow B: AES\text{-}GCM_{K_s}(Message)$
    *   *解释：* 使用 GCM 模式同时提供加密（Confidentiality）和完整性（Integrity/Authentication）。

---

### Q2: 拓扑与不相交路径 (Topology & Disjointness)

**核心任务：** 区分节点不相交与边不相交，并计算最小割。

**批判性解析：**
1.  **定义区分：**
    *   **边不相交（Edge-disjoint）：** 路径间没有公共边，但可能有公共中间节点。
    *   **节点不相交（Node-disjoint）：** 路径间没有公共中间节点（除了源和宿）。
    *   **陷阱：** 所有的节点不相交路径都是边不相交的，但反之不成立。
2.  **优劣势分析：**
    *   在有恶意节点（Adversary Node）的情况下，**节点不相交**绝对优于边不相交。
    *   **原因：** 如果三条路径共用一个中间节点 $X$，攻击者只要攻陷 $X$，就能控制所有路径。节点不相交迫使攻击者必须分别攻陷三条路径上的不同节点。
3.  **攻击阈值：**
    *   如果要完全阻断 Alice 和 Bob（即 Alice 无法发送甚至无法让 Bob 收到任何完整信息），攻击者需要攻陷 **3个节点**（每条路径上各一个）。这是基于图论中的 Menger 定理或最小割（Min-Cut）原理。

---

### Q3: 盲目随机路由与检测 (Oblivious Routing & Detection)

**核心任务：** 在概率选路下检测篡改（Tampering）和丢包（Dropping）。

**批判性解析：**
1.  **检测手段的区别：**
    *   **篡改（Tampering）：** 靠密码学手段检测。Bob 解密时检查完整性标签（MAC 或 GCM Tag）。如果校验失败，说明被篡改。
    *   **丢包（Dropping）：** 密码学救不了丢包。只能靠**协议逻辑**。即 **超时重传机制（ARQ, Automatic Repeat-reQuest）**。Alice 设定一个计时器，如果时间 $\tau$ 内未收到 ACK，则判定为丢包（或 ACK 丢失）。
2.  **扩充协议（Augmentation）：**
    *   需要在 Q1 的基础上增加：
        *   **Sequence Number ($Seq$):** 防止重传包导致的混淆。
        *   **ACK:** Bob 成功解密和校验后发送 ACK。
        *   **Timer:** Alice 发送后启动计时器。

---

### Q4: 延迟计算 (Probability & Delay) - 重点计算题

**核心任务：** 计算在特定攻击概率下的平均延迟。

**假设（Critical Assumptions）：**
*   重传时也是随机 1/3 选择路径。
*   路径之间没有传播延迟的差异，统一按 $\tau$ 算（这其实是简化，实际上不同路径延迟肯定不同，但按题意处理）。
*   **Packet Loss 的判定：** 无论是被篡改（Bob 丢弃）还是被直接丢弃（Bob 收不到），对 Alice 来说结果一样：**超时重传**。

**计算推导（一定要写公式）：**
这是一个**几何分布（Geometric Distribution）**问题。设 $X$ 为成功传输一条消息所需的尝试次数。
平均次数 $E[X] = \frac{1}{P_{success}}$。
总时间 $T = 10 \times E[X] \times \tau$。

1.  **场景 A: $p_{attack} = 1$ (红色路径全黑洞)**
    *   $P(选红) = 1/3 \rightarrow$ 失败 (概率 1) $\rightarrow$ 成功贡献 0。
    *   $P(选绿) = 1/3 \rightarrow$ 成功。
    *   $P(选蓝) = 1/3 \rightarrow$ 成功。
    *   单次尝试成功率 $P_s = 1/3 \times 0 + 1/3 \times 1 + 1/3 \times 1 = 2/3$。
    *   平均尝试次数 $E[X] = 1 / (2/3) = 1.5$ 次。
    *   **总延迟：** $10 \times 1.5 \times \tau = 15\tau$。

2.  **场景 B: $p_{attack} = 0.5$ (红色路径半丢半过)**
    *   $P(选红) \times P(红路通过) = 1/3 \times 0.5 = 1/6$。
    *   $P(选绿/蓝) = 2/3$。
    *   单次尝试成功率 $P_s = 1/6 + 2/3 = 1/6 + 4/6 = 5/6$。
    *   平均尝试次数 $E[X] = 1 / (5/6) = 1.2$ 次。
    *   **总延迟：** $10 \times 1.2 \times \tau = 12\tau$。

---

### Q5: 智能检测 (Intelligent Detection) - 难点

**核心任务：** 计算连续 $k$ 次丢包所需的平均传输次数（只看红色路径）。

**批判性解析（Pitfall）：**
这里最容易算错的是 $k \geq 2$ 的情况。注意这里考察的是**连续（Successive）**事件的期望等待时间。不能简单地认为是 $(1/p)^k$（那是发生一次特定 k 序列的概率倒数，但我们在流式传输，失败会重置计数）。

**计算模型：**
设 $E_k$ 为出现连续 $k$ 次丢包所需的平均步数。
$p = 0.5$ (丢包概率，即检测成功的“成功”概率)。

1.  **$k=1$ (平均多少次遇到第一个丢包):**
    *   几何分布，$E = 1/p = 1/0.5 = 2$ 次。

2.  **$k=2$ (平均多少次遇到连续两个丢包):**
    *   这是一个状态机问题。
    *   设 $x$ 为从初始状态到目标状态（连续2次丢包）的期望步数。
    *   **第一步：**
        *   50% 概率没丢（通过）：浪费了这一步，计数器清零，回到起点。代价：$0.5(1+x)$。
        *   50% 概率丢了：进入“已丢1次”状态。代价：$0.5 \times (\dots)$。
    *   **从“已丢1次”状态继续：**
        *   再走一步（第二步）。
        *   50% 概率没丢：前功尽弃（浪费了当前的1步和之前的1步，这已经在递归式里体现），回到起点。
        *   50% 概率丢了：目标达成。
    *   **通用公式：** 对于成功概率为 $p$ 的事件，连续出现 $k$ 次的期望次数为 $\frac{1-p^k}{p^k(1-p)}$。
    *   在本题中，我们要“连续丢包”，所以 $p_{event} = 0.5$。
    *   代入公式：$E = \frac{1 - 0.5^2}{0.5^2(1-0.5)} = \frac{0.75}{0.25 \times 0.5} = \frac{0.75}{0.125} = 6$。
    *   **结论：** 平均需要 **6次** 传输才能检测到（并丢弃该路径）。

---

### Q6: 智能对手 (Smart Adversary - Extra Credit)

**核心任务：** 博弈论。如果 E 知道规则，如何最大化伤害？

**策略分析：**
*   **对手目标：** 只有一条（最大化丢包）是不够的，还要**活着**（不被封禁）。
*   **对手策略：** 在连续丢弃 $k-1$ 个包后，**故意放行** 第 $k$ 个包。
*   **后果：** 路径评级机制永远不会触发（因为永远凑不齐 $k$ 个连续丢包）。

**伤害量化：**
*   **丢包率：** $\frac{k-1}{k}$。
*   **最坏情况 ($k=2$)：** 丢1个，放1个。丢包率 50%。
*   **最坏情况 (任意 $k$):** 随着 $k$ 增大，丢包率趋近于 100%（例如 $k=100$，丢99个放1个），而 Alice 永远无法自动切断该路径。
*   **批判性思考：** 这证明了简单的“连续 $k$ 次失败即封禁”的策略在面对智能攻击者时是脆弱的。应该使用基于**长期统计丢包率**的阈值，而不是连续性。

---

### Q7: 分片与冗余 (Fragmentation & Redundancy)

**核心任务：** 纠删码（Erasure Coding）策略下的延迟与检测。

**解题思路：**
1.  **冗余逻辑：** (2,3) 门限方案。数据分开走三条路。
2.  **检测：** 依然靠 MAC。如果红色路径分片被篡改，Bob 校验 MAC 失败，丢弃该分片。
3.  **恢复：** Bob 收到 绿色 和 蓝色 分片。校验通过。根据冗余算法（如 $M_1, M_2, M_1 \oplus M_2$）重构原消息。
4.  **关键差异：**
    *   因为只需要 3 条中的 2 条，且红色路径即使全丢 ($p_{attack}=1$) 也不影响另外两条。
    *   由于不需要重传，**每次发送都能一次性成功**。
    *   **延迟计算：** 传输 10 条消息，每条耗时 $\tau$（并发传输，取决于最慢的那条路，假设都是 $\tau$）。
    *   总延迟 = $10\tau$。
    *   **对比：** 这比 Q4 的 $15\tau$ (随机重传) 要快。

---

### Q8: 策略对比 (Strategy Comparison - Extra Credit)

**核心任务：** 权衡 Q4（重传）与 Q7（冗余）。

**批判性解析（核心得分点）：**
1.  **优势（Advantage）：**
    *   **低延迟与确定性：** Q7 提供了更低且更稳定的延迟（$10\tau$ vs 期望的 $15\tau$）。它把“时间上的重传”换成了“空间上的并发”。
    *   **抗干扰性：** 即使一条路径完全中断，通信完全不受影响，甚至不需要检测并切换路径（对此题中 $p=1$ 的情况极其有效）。

2.  **劣势（Disadvantage）- 需要量化的点：**
    *   **带宽开销（Bandwidth Overhead）：** 这是最大的坑。
    *   **Q4 策略：** 发送 1 个单位数据。虽然可能重传，但在 $p=1$ 时平均发送 1.5 次，即 1.5 单位流量。
    *   **Q7 策略：** 为了实现 (2,3) 冗余（即任意 2 份能恢复原始数据），通常分片的大小是原始数据的一半（例如 $S/2$）。
        *   共发送 3 个分片：$3 \times (S/2) = 1.5 S$。
        *   **流量对比：** 在 $p=1$ 时，Q7 的流量消耗 ($1.5S$) 和 Q4 的期望流量 ($1.5S$) 似乎打平了？
        *   **但是！** 还要考虑 **Header Overhead**（包头开销）。Q7 发送 3 个包，就有 3 个 IP/TCP/MAC 头部和 3 个加密开销（IV, MAC tag）。而 Q4 平均只发 1.5 个包。
        *   如果 $p=0$ (无攻击)，Q7 依然刚性消耗 $1.5S$ 的带宽，而 Q4 只需要 $1S$。
    *   **假设：** 假设网络带宽不是瓶颈。如果带宽紧张，Q7 可能导致网络拥塞，反过来增加 $\tau$。

通过这种结构化的解答，你不仅展示了数学能力，还展示了对协议设计权衡的深刻理解。