好的，这是对题目 **Exercise 4 Secure Link-State Routing** 的逐段中英对照翻译，以及随后的详细考点与“坑”点分析。

### 第一部分：中英逐段对照翻译

**Introductory Context (Context for Exercise 4)**

> **English:**
> Figure 3: Wireless multi-hop network topology. For Exercise 5, S is the source node and T the destination node.
> Consider the wireless multi-hop network in Fig. 3. Each line represents a wireless link, in other words signifying that the two nodes incident on a link are neighbors (i.e., communicate directly across the wireless medium, or, simply put, they are within range). If no link exists, then there is no direct connection. For example, F and H are out of range.

> **中文：**
> 图3：无线多跳网络拓扑。对于练习5，S是源节点，T是目的节点。
> 考虑图3中的无线多跳网络。每一条线代表一条无线链路，换句话说，这意味着连接在一条链路上的两个节点是邻居（即，通过无线介质直接通信，或者简单地说，它们在彼此的通信范围内）。如果不存在连线，则没有直接连接。例如，F和H彼此超出了通信范围。

> **English:**
> Communication is locally a broadcast: e.g., a packet sent by A goes simultaneously over (A,S), (A,B), (A,D), and (A,E). Nonetheless, the local, node-to-node transmission can be a uni-cast, e.g., a message specifically sent from A to B as the sole intended receiver; given the wireless channel, such a message can be received by the other neighbors, S, D, E.

> **中文：**
> 通信在“本地”是广播形式的：例如，A发送的数据包会同时经过 (A,S)、(A,B)、(A,D) 和 (A,E) 传输。尽管如此，本地的点对点传输可以是单播（uni-cast），例如，一条专门从A发送给B的消息，B是唯一的预期接收者；但鉴于无线信道的特性，该消息仍可能被其他邻居（S、D、E）收到。

**Exercise 4 Prompt**

> **English:**
> **Exercise 4 Secure Link-State Routing (50 points + 30 points extra credit)**
> Consider first a secure link state routing protocol run by all the nodes. Each node be equipped with a public/private key pair and a certificate; all certificates are provided by the same CA. Nodes/routers can be considered loosely synchronized. Adjacent routers can be assumed to share symmetric keys. Please recall that routers broadcast Link State Advertisements (LSAs), communicating links to their neighbors, to all other routers.

> **中文：**
> **练习 4：安全链路状态路由（50分 + 30分额外加分）**
> 首先考虑一个由所有节点运行的安全链路状态路由协议。每个节点都配备了一对公钥/私钥和一个证书；所有证书均由同一个 CA（认证中心）提供。可以认为节点/路由器之间是松散时间同步的。可以假设相邻的路由器之间共享对称密钥。请回想一下，路由器会广播链路状态通告（LSA），将其与邻居的链路连接情况告知所有其他的路由器。

**Question 1**

> **English:**
> 1. Please describe how a malicious router, M, can attempt to (a) introduce inexistent links connecting it to B and F and the inexistent Z, Y, and W routers, and (b) add two fictitious links connecting B and J and C and K.

> **中文：**
> 2. 请描述一个恶意路由器 M 如何尝试做到以下几点：(a) 引入并不存在的链路，将它自己连接到 B 和 F，以及连接到并不存在的路由器 Z、Y 和 W；(b) 添加两条虚构的链路，分别连接 B 和 J 以及 C 和 K。

**Question 2**

> **English:**
> 2. Discuss how likely it is for M to succeed when there is adjacent router authentication; e.g., $G \rightarrow H : m, MAC_{K_{GH}} (m)$, that is, for any message $m$ G passes to a neighbor H, there is an authenticator, e.g., a Message Authentication Code (MAC), using the shared key $K_{GH}$.

> **中文：**
> 3. 讨论当存在相邻路由器认证时，M 成功的可能性有多大？例如，$G \rightarrow H : m, MAC_{K_{GH}} (m)$，即对于 G 传递给邻居 H 的任何消息 $m$，都有一个认证符，例如使用共享密钥 $K_{GH}$ 生成的消息认证码（MAC）。

**Question 3**

> **English:**
> 3. Augment the protocol by using public key cryptography; how could you prevent the attacks (a) and (b)? Explain the new LSA format and the operations at the sending and the receiving nodes and explain why attacks are thwarted (or not).

> **中文：**
> 4. 利用公钥密码学来增强该协议；你如何防止攻击 (a) 和 (b)？请解释新的 LSA 格式以及发送节点和接收节点的操作，并解释为什么这些攻击会被阻断（或者为什么不能被阻断）。

**Question 4**

> **English:**
> 4. What if a link changes or breaks? Could M replay an older LSA and mislead the network the link remains intact? Explain why, based on earlier assumptions; or augment your protocol to thwart such an attack. Can M remove an operational link connecting two other routers, e.g., D and H?

> **中文：**
> 5. 如果一条链路发生变化或断开会怎样？M 是否可以重放旧的 LSA 并误导网络认为该链路仍然完好？请基于之前的假设解释原因；或者增强你的协议以挫败此类攻击。M 是否可以移除连接其他两个路由器（例如 D 和 H）的正常运行的链路？

**Question 5**

> **English:**
> 5. Is it useful to maintain node-node, i.e., router-to-neighboring router, symmetric key based authentication when LSAs are protected based on public key cryptography? How many certificates does a node, S, need to have in order to be able to obtain a complete view of the topology.

> **中文：**
> 6. 当 LSA 已经基于公钥密码学进行保护时，维持节点到节点（即路由器到相邻路由器）的基于对称密钥的认证是否有用？为了获得完整的网络拓扑视图，一个节点 S 需要拥有多少个证书？

**Question 6 (Extra Credit)**

> **English:**
> 6. Extra credit, 30 points
> (i) How can your protocol detect an attacker that transmits LSAs at an excessive rate? Please make any necessary assumptions. What if a benign router, J, receives excessive LSAs by M and forwards them? Could J be flagged as adversarial by its neighbors?
> (ii) What if the topology were highly dynamic? Could benign, correct routers be flagged as transmitting LSAs, honestly reflecting the latest network topology, at an excessive rate? If yes, how would you augment the protocol to avoid this?
> (iii) Please discuss the trade-off of your suggestion(s) in (ii).

> **中文：**
> 7. 额外加分（30分）
> (i) 你的协议如何检测以过高速率发送 LSA 的攻击者？请做出任何必要的假设。如果一个良性路由器 J 接收到了 M 发送的大量 LSA 并转发了它们，J 会被它的邻居标记为敌对节点吗？
> (ii) 如果网络拓扑是高度动态的会怎样？诚实地反映最新网络拓扑、发送 LSA 的良性正确路由器，会被标记为以过高速率发送 LSA 吗？如果是，你会如何增强协议以避免这种情况？
> (iii) 请讨论你在 (ii) 中建议的权衡（Trade-off）。

---

### 第二部分：题目分析与解题“避坑”指南

这道题考察的是典型的 **Link-State Routing (链路状态路由)** 安全机制（类似于增强版的 OSPF 或 IS-IS 安全）。这类题目往往在“认证模型”和“威胁模型”的细节上设有陷阱。

以下是你需要特别注意的“坑”和关键点：

#### 1. 关于第 1 题（攻击方式）的陷阱
*   **谎报自己的连线 vs. 谎报他人的连线：**
    *   **(a) M 声称连接到 B, F, Z, Y, W：** 在标准的链路状态协议中，路由器负责报告**它自己的**邻居。因此，M 可以在它自己的 LSA 中写入“我是 M，我的邻居是 B、F...”。这是协议允许的“格式”，尽管内容是假的。
    *   **(b) M 声称 B-J 和 C-K 相连：** 这是一个陷阱。M 能够生成声称 $B \leftrightarrow J$ 的 LSA 吗？在没有签名保护的情况下，M 可以伪造一个看起来像是 B 发出的 LSA，或者伪造一个 C 发出的 LSA。你需要区分 M 是在**自己的 LSA** 里写这个（这是无效的，因为协议只信你自己报自己的邻居），还是 M **伪造了别人的 LSA**（Spoofing）。题目这里的语境通常是指 M 试图欺骗全网，你需要描述 M 是如何注入虚假信息的。

#### 2. 关于第 2 题（邻居认证的局限性）的陷阱 **(高频考点)**
*   **逐跳认证 (Hop-by-Hop) vs. 端到端认证 (End-to-End)：**
    *   题目中提到的 MAC 使用的是 $K_{GH}$（相邻节点共享密钥）。这只能证明**数据包是从邻居发过来的**。
    *   **核心坑点：** 这种认证**无法验证 LSA 内容的真实性**。
    *   如果 M 是网络中的合法成员，它拥有与邻居的共享密钥。M 可以制造一个包含谎言（例如“我连接了 Z”）的 LSA，然后用正确的密钥计算 MAC 发给邻居。邻居会验证 MAC 通过（因为确实是 M 发的），然后把这个包含谎言的 LSA 扩散到全网。
    *   **结论：** 相邻认证只能防止外部入侵者（Outsider），无法防止内部攻击者（Insider M）撒谎，也无法防止 M 伪造别人的 LSA 内容（如果 LSA本身没有签名保护的话）。

#### 3. 关于第 3 题（公钥保护）的细节
*   **谁签名？** 需要明确指出，每个 LSA 必须由**发起者 (Originator)** 签名。
*   **双向验证问题（Two-way connectivity）：**
    *   仅仅 M 签名说 "M与B相连" 是不够的。如果 B 是诚实的，B 的 LSA 里不会写 "B与M相连"。
    *   **关键防御机制：** 安全路由通常要求链路是双向确认的。如果 M 的 LSA 说有 Link(M,B)，但 B 的 LSA 里没有 Link(B,M)，其他节点计算路由时应该忽略这条单向链路。这是防止 M 凭空捏造与良性节点（如 B、F）连接的关键。
    *   对于虚构节点（Z, Y, W），因为它们不存在，M 可能通过生成虚假的密钥对来伪造这些“幽灵”节点并互相签名。你需要提到 CA 的作用——M 无法为 Z, Y, W 获取合法的 CA 证书，因此无法通过身份验证。

#### 4. 关于第 4 题（重放与移除）
*   **重放攻击 (Replay)：** 题目在 Intro 中提到“Loosely synchronized”（松散同步）。这是一个提示。
    *   通常防止重放用 **Sequence Number (序列号)**，但在重启或回滚时有问题。
    *   既然有时钟，可以用 **Timestamp (时间戳)** 作为主要或辅助手段。
    *   **坑：** 如果只说加签名，没说加 nonce/seq/timestamp，那么攻击者只要把旧的、带有合法签名的 LSA 重新广播一遍，网络就会以为旧链路恢复了。
*   **移除链路 (Removal)：**
    *   M 很难直接移除 $D \leftrightarrow H$。因为移除链路需要 D 或 H 发出一个新的 LSA 说“我不再连接 H 了”。M 无法伪造 D 或 H 的签名。
    *   M 唯一能做的是**干扰 (Jamming)** 物理层，或者如果在路由路径上，通过**丢包 (Blackhole)** 造成通信中断，但这不属于“欺骗路由协议认为通过 D-H 的拓扑不存在”。

#### 5. 关于第 5 题（混合认证与证书数量）
*   **混合认证的必要性：** 不要急着说“没用”。公钥运算很慢（CPU消耗大），容易被用于 DoS 攻击。保留对称密钥 MAC 可以作为第一道防线，快速过滤掉非邻居发来的垃圾包，保护 CPU 资源。
*   **证书数量：** 这是一个关于“全局视图 (Global View)”的问题。在链路状态协议中，每个节点都需要验证整个网络中**所有其他节点**的 LSA 签名。因此，S 可能需要所有其他 N-1 个节点的公钥/证书来验证它们的 LSA。

#### 6. 关于第 6 题（泛洪与动态拓扑）
*   **良性与恶意的区分：**
    *   如果 M 狂发包，邻居 J 转发。如果 J 的邻居把 J 封了，那就是 DoS 攻击成功了（借刀杀人）。
    *   **解决思路：** 惩罚机制应该基于 **Original ID (源ID)** 而不是 **Transmitter (转发者)**。应该识别出是 M 生成了过多的 LSA，而不是 J 转发了它们。
*   **动态拓扑 (Flapping)：**
    *   如果网络不稳定，链路频繁断连，合法的 LSA 也会很多。
    *   **Trade-off：** 设置速率限制（Rate Limiting）或阻尼（Dampening）。
    *   **代价：** 会导致网络对真实拓扑变化的**收敛速度变慢 (Slower Convergence)**。安全性和性能/敏捷性永远是一对矛盾。

---

**总结建议：**
在回答时，请务必区分 **Authentication (他是谁)** 和 **Authorization/Veracity (他说的话是否可信)**，以及区分 **Origin Authentication (源认证)** 和 **Neighbor Authentication (邻居认证)**。这些区分是拿分的关键。

---
这是一个关于**安全链路状态路由协议（Secure Link-State Routing Protocol）**设计的经典练习题。它主要考察你对路由协议工作原理（如 OSPF）与密码学原语（MAC、数字签名、PKI）结合应用的理解。

以下是该问题的详细解答。

---

### **练习 4：安全链路状态路由 详细解答**

#### **1. 恶意路由器 M 的攻击描述**

**问题回顾：** M 如何尝试 (a) 引入不存在的链路把自己连接到 B, F, Z, Y, W；(b) 添加 B-J 和 C-K 的虚假链路。

**解答：**
在标准的链路状态路由协议中，每个路由器都会生成一个 **LSA (链路状态通告)**，列出它自己的所有邻居，并广播给全网。

*   **(a) 谎报自己的连接 (Lying about own links):**
    由于 M 是网络中的合法路由器，它可以生成并广播一个**合法的 LSA 数据包**。
    *   M 在它自己的 LSA 中写入内容：`Origin: M, Neighbors: {B, F, Z, Y, W}`。
    *   它将此 LSA 广播给实际的邻居。由于协议目前没有验证内容的机制，网络中的其他节点会接收并记录“M 声称它与 B, F 以及 Z, Y, W 连通”。
    *   对于 Z, Y, W 这种根本不存在的节点，M 仅仅是在列表里编造了几个 ID 而已。

*   **(b) 伪造他人的连接 (Spoofing other links):**
    要添加 B-J 和 C-K 的链路，M 必须伪装成 B、C、J 或 K。
    *   因为链路状态协议只允许节点报告**自己**的直接连接。M 不能在其自己的 LSA 中说“B 和 J 相连”。
    *   M 必须实施**伪造 (Spoofing)** 攻击。M 构造一个假的数据包，看起来像是从 B 发出的，内容为 `Origin: B, Neighbors: {J, ...}`。
    *   同样，M 构造另一个假包，看起来像是从 C 发出的，内容为 `Origin: C, Neighbors: {K, ...}`。
    *   M 将这些伪造的数据包注入网络。

---

#### **2. 相邻路由器认证 (MAC) 的有效性分析**

**问题回顾：** 如果存在 $G \rightarrow H : m, MAC_{K_{GH}} (m)$ 的逐跳认证，M 成功的可能性？

**解答：**
**M 极有可能（Very Likely）成功实施上述攻击。**

*   **原因分析：**
    *   题目中描述的认证是 **逐跳认证 (Hop-by-Hop Authentication)**。也就是 A 只验证消息是不是它的邻居 M 发给它的。
    *   M 是网络中的合法成员（Insider），它拥有与邻居（如 A）的合法共享密钥 $K_{MA}$。
    *   当 M 发送含有谎言的 LSA（攻击 a）或者伪造 B 的 LSA（攻击 b）时，M 会使用它与 A 的共享密钥 $K_{MA}$ 为该数据包计算一个正确的 MAC。
    *   **验证过程：** 邻居 A 收到数据包，验证 MAC 通过（证明这确实是 M 发来的），然后 A 就会信任该数据包并将其加入数据库并转发给其他节点。
    *   **核心缺陷：** MAC 只能证明“**谁发送了这个包给下一跳**”，而不能证明“**谁最初生成了这个包**”（缺乏源认证/Origin Authentication）。因此，逐跳认证无法防止内部攻击者撒谎或伪造他人的 LSA 内容。

---

#### **3. 使用公钥密码学增强协议**

**问题回顾：** 使用 PKI 增强协议，如何防止 (a) 和 (b)？解释新格式和操作。

**解答：**

**新 LSA 格式：**
LSA 必须包含由生成该 LSA 的路由器（Originator）使用其私钥生成的**数字签名**。
```text
LSA = { [Sequence Number, Origin_ID, Neighbors_List, Timestamp] || Signature_Origin_Private_Key }
```

**节点操作：**
*   **发送节点 (S)：** 创建 LSA 内容，计算内容的哈希值，用 S 的**私钥**对哈希进行签名，将签名附在 LSA 后。
*   **接收节点 (R)：** 收到任何 LSA 时，查看 `Origin_ID`。提取该 ID 对应的**公钥**（从证书中获取）。使用公钥验证签名。
    *   如果签名有效：接受并在本地数据库更新，继续转发。
    *   如果签名无效：丢弃。

**如何防御攻击：**

*   **针对攻击 (b) (伪造 B-J, C-K)：** **完全被阻断 (Thwarted)。**
    *   M 想要伪造 `Origin: B` 的 LSA，但 M 没有 B 的私钥。
    *   M 无法生成有效的 `Signature_B`。
    *   任何收到该伪造 LSA 的节点，在用 B 的公钥验证签名时都会失败，从而丢弃该包。

*   **针对攻击 (a) (谎报 M-B, M-F, M-Z...)：** **部分阻断，结合拓扑检查。**
    *   M 可以用自己的私钥给“我连接了 B、Z...”这一谎言签名。签名本身是合法的。
    *   **防御机制：双向连通性检查 (Two-way Connectivity Check)。**
        *   路由协议的逻辑层必须规定：只有当 **M 说它连接了 B** 且 **B 也说它连接了 M** 时，链路 M-B 才被视为存在。
        *   对于真实节点 B 和 F：B 和 F 是诚实的，它们的 LSA 不会列出 M（假设实际上没连接）。因此 M 的单方面声明会被忽略。
        *   对于虚假节点 Z, Y, W：M 声称连接了 Z。但 Z 不存在，网络中永远不会传播出由 Z 签名且包含 `Neighbors: {M}` 的合法 LSA（甚至 Z 根本没有 CA 颁发的证书）。因此双向检查失败。

---

#### **4. 链路变化、重放攻击与移除链路**

**问题回顾：** 链路变化或断开，M 能否重放旧 LSA？M 能否移除 D-H 链路？

**解答：**

*   **重放攻击 (Replay Attack)：**
    *   如果 M 捕获了过去 M 和 B 连接正常时 B 发出的旧 LSA，并在连接断开后重新广播，即使有签名，网络也可能受骗。
    *   **防御增强：** 必须在 LSA 中包含 **序列号 (Sequence Number)** 和/或 **时间戳 (Timestamp)**。
        *   路由器只接受序列号比当前缓存的序列号更新的 LSA。
        *   或者，由于题目假设“松散同步”，可以检查 LSA 中的时间戳是否在允许的有效期内（例如过去 10 分钟内）。过期或旧序列号的 LSA 会被直接丢弃。

*   **移除链路 (Removal of D-H)：**
    *   **M 无法通过协议手段移除 D-H。**
    *   要移除 D-H，网络需要收到 D 发出的（并签名的）新 LSA 说“我的邻居列表里没有 H 了”，或者 H 发出的新 LSA。
    *   由于 M 无法伪造 D 或 H 的签名，它无法伪造特定内容的 LSA 来“注销”这条链路。
    *   *注：M 只能通过物理层干扰（Jamming）或如果是 D-H 通信的中间人则进行丢包（Blackhole），但这属于拒绝服务，不属于篡改路由协议逻辑。*

---

#### **5. 混合认证与证书数量**

**问题回顾：** 有了公钥保护，对称密钥认证还有用吗？S 需要多少证书？

**解答：**

*   **对称密钥认证的用处：**
    *   **非常有用 (Yes, it is useful)。**
    *   公钥验证（RSA/ECDSA）的计算成本很高，消耗 CPU 资源。
    *   如果是公钥验证，攻击者可以向路由器发送数百万个垃圾签名，耗尽路由器的 CPU（DoS 攻击）。
    *   **对称密钥 (MAC) 作为第一道防线：** 路由器可以先验证数据包是否来自合法的邻居（计算 MAC 很快）。只有 MAC 验证通过，才去进行昂贵的公钥签名验证。这保护了路由器的控制平面资源。

*   **S 需要的证书数量：**
    *   在链路状态协议中，每个路由器都要根据全网所有其他路由器发来的 LSA 构建完整的拓扑图。
    *   因此，S 需要验证网络中**每一个**路由器发出的 LSA 的签名。
    *   假设网络有 $N$ 个节点，S 需要拥有 **所有其他节点的公钥/证书**（即 $N$ 个或 $N-1$ 个，再加上 CA 的根证书）。

---

#### **6. 额外加分题 (Extra Credit)**

**问题 (i)：检测高速率 LSA 攻击**

*   **检测方法：**
    *   节点应该基于 **LSA 的源 ID (Originator ID)** 来统计频率，而不是基于上一跳发送者。
    *   每个路由器维护一个表，记录每个 Origin ID 在单位时间内生成 LSA 的数量。
    *   如果来自 M 的 LSA 更新频率超过阈值（例如每秒 > 5 次），则判定 M 为攻击者。

*   **良性路由器 J 的问题：**
    *   如果 J 只是转发 M 的垃圾数据，**J 不应该被标记为敌对节点**。
    *   因为有了公钥签名，邻居可以明确区分“载体”(J) 和“制造者”(M)。邻居会验证出这些过量的 LSA 都是 M 签名的。
    *   策略应该是：**丢弃 M 签名的包，并将 M 拉入黑名单，但保持与 J 的连接。** J 是受害者，不是攻击者。

**问题 (ii)：高度动态拓扑 (Flapping) 问题**

*   **问题：** 如果拓扑震荡（Flapping，例如链路物理不稳定），诚实的路由器会频繁发送 LSA 更新，确实可能被误判为 DoS 攻击者。
*   **增强方案：LSA 阻尼 (Route Flapping Damping)。**
    *   不应该直接封禁诚实节点，而应该实施**速率限制 (Rate Limiting)** 或 **指数退避 (Exponential Backoff)**。
    *   例如：如果一个链路在短时间内状态变化多次，路由器应该强制增加发送下一次更新的间隔时间（例如：第1次立即发，第2次等5秒，第3次等30秒...）。
    *   接收端也可以配置策略：如果某 ID 更新过于频繁，暂时忽略该 ID 的更新一段时间（Suppress），而不是标记为恶意节点。

**问题 (iii)：权衡 (Trade-off)**

*   **一致性 vs. 稳定性 (Consistency vs. Stability):**
    *   实施阻尼（Dampening）的主要代价是**网络收敛变慢 (Slower Convergence)**。
    *   当网络拓扑真的发生变化时，由于为了防止攻击或震荡而限制了 LSA 的发送频率，其他路由器可能要过一段时间才能得知最新的路径。
    *   在这段延迟期间，网络视图是不一致的，可能导致路由黑洞（Packet Loss）或路由环路（Routing Loops）。
    *   这是一场在“防止控制平面过载”与“保持数据平面连通性”之间的博弈。
如果 M **不是**网络中的合法成员（即 M 是一个 **外部攻击者 / Outsider**），那么在第 2 问描述的场景下（存在基于对称密钥的相邻路由器认证），M **几乎不可能**实现上述攻击。

以下是详细的分析：

### 1. 核心障碍：缺乏共享密钥

在第 2 问的设定中，路由器之间的通信受到如下保护：
$$G \rightarrow H : m, MAC_{K_{GH}} (m)$$

这意味着任何一个节点（比如 H）在接收并处理来自邻居的消息之前，会进行以下检查：
1.  **身份验证：** 发送者拥有与我共享的密钥 $K$ 吗？
2.  **完整性验证：** MAC 码是否与消息内容匹配？

**如果 M 是外部攻击者：**
*   M 没有经过 CA 认证，也没有网络管理员配置的凭证。
*   因此，M **没有**与网络中任何合法路由器（例如邻居 A）建立共享的对称密钥 $K_{MA}$。

### 2. 攻击场景推演

让我们看看 M 试图实施攻击时会发生什么：

*   **攻击尝试：** M 构造了一个恶意的 LSA（无论是谎报自己的连接，还是伪造别人的连接），试图将其注入网络。M 将这个数据包发送给物理范围内的一个合法路由器 R。

*   **接收端 R 的反应：**
    *   R 收到数据包后，根据协议要求，R 期待数据包附带一个基于 $K_{MR}$ 计算的 MAC。
    *   **情况 A（M 瞎编 MAC）：** M 没有密钥，只能随机生成或瞎编一个 MAC。R 使用即时持有的密钥计算 $MAC_{check}$，发现与 M 发送的不匹配。$\rightarrow$ **丢包**。
    *   **情况 B（M 不发 MAC）：** M 发送不带 MAC 的明文包。R 的协议栈发现缺少强制的认证字段。$\rightarrow$ **丢包**。

### 3. "重放攻击"在这里有用吗？

虽然外部攻击者通常可以进行**重放攻击 (Replay Attack)**（即录制合法数据包并重新发送），但在这种特定情况下，重放攻击无法帮助 M 实现题目的目标：

*   **题目的目标是：** 引入**不存在**的链路（连接到 Z, Y, W）或**虚构**的链路（B-J）。这需要 M **修改** LSA 的内容（Payload）。
*   一旦 M 修改了 LSA 的内容（message $m$ 变了），之前录制的合法 MAC 就失效了，因为 MAC 是基于内容计算的 $MAC(m, K)$。
*   M 无法为修改后的内容计算新的有效 MAC。

### 4. 结论与总结

**结论：** 外部攻击者 M **无法**实施攻击 (a) 和 (b)。

**系统设计的意义（Takeaway）：**
这正是**相邻路由器认证（Neighbor Authentication / Link-layer Security）**存在的主要意义：
*   它并不是用来防**内鬼（Insider）**的（如上一条回答所述，内鬼有密钥，可以撒谎）。
*   它是一道防火墙，专门用来防**外人（Outsider）**的。它确保只有持有合法凭证的设备才能参与路由协议的交互，防止外部未经授权的设备注入垃圾数据或欺骗数据。

**简而言之：**
*   **M 是内鬼：** 对称密钥认证**无效**，M 可以撒谎成功。
*   **M 是外人：** 对称密钥认证**非常有效**，M 直接被挡在门外。