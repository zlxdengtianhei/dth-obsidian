以下是该题目（练习 5）的逐段中英对照翻译，以及针对题目中潜在难点（“坑”）和答题注意事项的深度分析。

### 第一部分：中英逐段对照翻译

**Exercise 5 Secure Reactive Route Discovery (80 points + 30 points extra credit)**
**练习 5 安全反应式路由发现（80分 + 30分 附加分）**

---

**With reference to Fig. 3 again, consider a route discovery initiated by S, using the Secure Routing Protocol (SRP): it sends a RREQ, looking for a route to T. Recall that each intermediate node, A,...,M, rebroadcasts each fresh RREQ once. Otherwise, it ignores a previously heard RREQ. Each route discovery is identified by a sequence number, QSEQ, and a random QID.**
再次参考图 3，考虑由节点 S 发起的一次路由发现过程，该过程使用安全路由协议（SRP）：S 发送一个 RREQ（路由请求），寻找通往 T 的路由。回想一下，每个中间节点（A,...,M）只会重播（Rebroadcast）每个**新鲜的**（Fresh）RREQ 一次。否则，它将忽略之前已经听到的 RREQ。每次路由发现都由一个序列号 QSEQ 和一个随机查询标识符 QID 来唯一标识。

---

**Assume that S and T already share a symmetric key and with this one they can calculate a Message Authentication Code (MAC). You can assume the availability of public-private keys and certificates.**
假设 S 和 T 已经共享了一个对称密钥，并且利用这个密钥他们可以计算消息认证码（MAC）。你可以假设公钥-私钥对和证书也是可用的。

---

**1. Recall that each intermediate node adds its identity to the RREQ they re-broadcast. Please describe the RREQ propagation, e.g., over A, D and H, etc, or any other path you prefer. Recall, however, that each node ’knows’ (has a security association with) at most its neighbors and the destination(s) it needs to communicate with. In this case, S knows T and can discover A, B, and C.**
**1.** 回想一下，每个中间节点都会将其身份添加到它们重播的 RREQ 中。请描述 RREQ 的传播过程，例如经过 A、D 和 H 等，或者你喜欢的任何其他路径。但请记住，每个节点至多只“认识”（即与其拥有安全关联）它的邻居节点以及它需要通信的目标节点。在这种情况下，S 认识 T，并且可以发现（也是邻居）A、B 和 C。

---

**2. Briefly discuss secure neighbor discovery, taking place asynchronously and in a sense proactively, before a route discovery is initated.**
**2.** 简要讨论一下安全邻居发现（Secure Neighbor Discovery），这通常在路由发现发起之前，以异步且某种意义上是主动的方式发生。

---

**3. Consider a RREP crafted by T with the following fields:**
• **QSEQ**
• **{T,M,J,G,B,S}**
• **MAC_KS,T ({T,M,J,G,B,S},QSEQ)**
**Is it a valid RREP? If not, please provide a valid RREP in response to the RREQ you described in part 1, above, for this exercise. Please explain how this or any RREP reaches back the source of the corresponding RREQ, i.e., S in our network, and how it is validated by S.**
**3.** 考虑由 T 构建的包含以下字段的 RREP（路由回复）：
• QSEQ
• {T,M,J,G,B,S}
• MAC_KS,T （消息认证码，基于 S 和 T 的共享密钥，内容包括 {T,M,J,G,B,S} 和 QSEQ）
这是一个有效的 RREP 吗？如果不是，请针对你在本题第 1 部分中描述的 RREQ，提供一个有效的 RREP。请解释这个 RREP（或任何 RREP）是如何传回对应 RREQ 的源头（即我们网络中的 S）的，以及 S 是如何验证它的。

---

**4. Given the RREQ propagation and RREP you described it thus far, can an adversary, E, prevent legitimate RREQs by S from being processed by D, C, ..., G, the adversary’s neighbors? Explain why not, or why yes, and if yes please fix the problem.**
**4.** 基于你目前描述的 RREQ 传播和 RREP，攻击者 E 是否能阻止 S 发出的合法 RREQ 被 E 的邻居（如 D、C、...、G）处理？请解释为什么不能，或者为什么能；如果是后者，请解决这个问题。

---

**5. Now, set aside the assumption that S and T already share a symmetric key. Instead, assume that they each has a public-private key pair and a certificate provided by the same certification authority. How can you modify the SRP route discovery using public key cryptography? In particular, can you have a protocol that allows S and T to establish a shared key simultaneously with the route discovery? State your notation, assumptions and describe your protocol. Explain briefly why the same security is achieved now as that based on the pre-established symmetric key holds. How can either of the two confirm that the established symmetric key is successfully obtained by the other party? (Hint: this will differ, depending on whether you used a transport or agreement approach)**
**5.** 现在，抛开 S 和 T 已经共享对称密钥的假设。相反，假设它们各自拥有由同一认证机构（CA）提供的公私钥对和证书。你如何利用公钥密码学来修改 SRP 路由发现协议？特别是，你能否设计一个协议，允许 S 和 T 在进行路由发现的**同时**建立一个共享密钥？请说明你的符号表示、假设条件并描述你的协议。简要解释为什么现在通过公钥机制能达到与之前基于预共享对称密钥相同的安全性。通信双方中的任何一方如何确认对方已成功获得了建立的对称密钥？（提示：这取决于你使用的是密钥传输（Transport）方法还是密钥协商（Agreement）方法，答案会有所不同）

---

**6. For either of the above variants of SRP, consider now B as an adversary that attempt to “hide” itself from the discovered route. For example, can B mislead S and T that they are connected by a route {S,E,G,J,M,T}? If successful, what is the effect of such an attack, why does B perpetrate it?**
**6.** 对于上述任一种 SRP 变体，现在考虑 B 是一个试图在已发现的路由中“隐藏”自己的攻击者。例如，B 能否误导 S 和 T，使他们以为彼此是通过路由 {S,E,G,J,M,T} 连接的（而实际上 B 也在路径中但未显示）？如果攻击成功，这种攻击会有什么影响？B 为什么要这么做？

---

**7. What if each pair of nodes runs periodically a secure neighbour discovery protocol and use such information as a precursor to any route discovery? That is, as you discussed in part 2 above, a protocol that ensures them that they are neighbours or equivalently that their communication link is up? E.g., S knows that (S,A), (S,B) and (S,C) are up (or equivalently that A, B and C are neighbours. You can assume that the network topology changes slowly enough so that none of these links goes down before the end of the subsequent route discovery. If you answered yes to the previous question 6, is the attack now stopped? If not, please explain.**
**7.** 如果每对节点都周期性地运行安全邻居发现协议，并使用这些信息作为任何路由发现的前置条件，情况会怎样？也就是说，正如你在第 2 部分中讨论的那样，该协议确保它们是邻居，或者等效地确保它们的通信链路是连通的。例如，S 知道 (S,A)、(S,B) 和 (S,C) 是连通的（或者说 A、B 和 C 是邻居）。你可以假设网络拓扑变化足够缓慢，使得在随后的路由发现结束之前，这些链路都不会断开。如果你在问题 6 中回答“是”（即攻击可行），那么现在这个攻击被阻止了吗？如果没有，请解释原因。

---

**8. Next, consider B and M being adversaries that collude, i.e., work together. Can they manipulate the route discovery so that they mislead S and T that they are connected by a route {S,B,M,T}? If yes, please outline their attack, what they need to know/have and how to evade the controls of SRP. What is the effect of such an attack, why do B and M perpetrate it? If they cannot, explain how the protocol stops such an attempt.**
**8.** 接下来，考虑 B 和 M 是串通（Collude）的攻击者，即它们协同工作。它们能否操纵路由发现，从而误导 S 和 T 以为彼此是通过路由 {S,B,M,T} 连接的？如果可以，请概述它们的攻击方式、它们需要知道/拥有什么，以及如何规避 SRP 的控制。这种攻击的影响是什么？B 和 M 为什么要这么做？如果它们不能，请解释协议如何阻止这种企图。

---

**9. Extra credit, 30 points What is the message (RREQ plus RREP messages) complexity of the route discovery? Can the protocol discover multiple routes or only one? If multiple routes can be discovered, are they disjoint? If so, which protocol, the secure link state routing protocol in the previous exercise or the SRP, is more likely to provide S with all available disjoint paths? How would the answers change if each intermediate node retransmitted (locally broadcasted) two copies of the same RREQ? What if mobility allows nodes to encounter nodes, establish keys or learn their certificates and public keys - can this be used to augment SRP and improve security? Sketch how.**
**9. 附加分，30分** 路由发现的消息复杂度（RREQ 加上 RREP 消息）是多少？该协议能发现多条路由还是只能发现一条？如果能发现多条路由，它们是不相交的（Disjoint）吗？如果是，那么前一个练习中的安全链路状态路由协议和 SRP 相比，哪一个更有可能为 S 提供所有可用的不相交路径？如果每个中间节点重传（本地广播）同一 RREQ 的两个副本，答案会有什么变化？如果移动性允许节点在相遇时建立密钥或学习彼此的证书和公钥 —— 这能否用于增强 SRP 并提高安全性？请简述如何实现。

---

### 第二部分：题目分析与答题“坑”点提示

这道题考察的是移动自组网（MANET）中的安全路由，特别是类似 **SRP (Secure Routing Protocol)** 的机制。与链路状态协议（全网拓扑已知）不同，这里是**反应式（按需）**路由。

以下是使用信息图整理的关键考点与“避坑”指南：

```infographic list-grid-badge-card
theme
  name: "trap-analysis"
data
  title: "Exercise 5: Strategic Analysis & Pitfalls"
  items:
    - label: "Knowledge Scope"
      desc: "SRP/DSR is Source Routing but strictly Hop-by-Hop discovery."
      icon: "mdi:eye-off-outline"
      detail: "Trap: Do not assume S knows the whole topology. S only knows neighbors. T verifies the full path integrity via MAC, but T implies trust in the reported IDs."
    - label: "RREP Validity"
      desc: "Path direction and MAC verification are critical."
      icon: "mdi:check-decagram"
      detail: "Trap: RREQ accumulates path S->T. RREP usually carries T->S or the accumulated S->T path. The MAC must key off S&T's shared secret. Does it include the correct fields? Is the path reversed correctly?"
    - label: "Rushing Attack"
      desc: "Q4 hints at Denial of Service via 'First Valid Packet' rule."
      icon: "mdi:run-fast"
      detail: "Trap: Nodes drop duplicate RREQs (Same QID). If Adversary broadcasts fast, legitimate slower RREQs are dropped. This prevents route discovery through honest nodes."
    - label: "Key Establishment"
      desc: "Q5: Public Key Overhead vs. Security."
      icon: "mdi:key-change"
      detail: "Trap: Diffie-Hellman (DH) or Key Transport. You must protect against Man-in-the-Middle (MITM). Simply sending keys isn't enough; you must SIGN the exchange with the long-term Keys/Certs."
    - label: "Node Hiding"
      desc: "Q6 & Q7: Verification of neighbor adjacency."
      icon: "mdi:ghost-outline"
      detail: "Trap: If B simply deletes its ID from the RREQ list, can T detect it? With strict Neighbor Discovery (Q7), S checks if (S,E) exists. If S sees B but list says E, it's a conflict."
    - label: "Collusion/Wormhole"
      desc: "Q8: Tunneling packets between adversaries."
      icon: "mdi:tunnel-outline"
      detail: "Trap: Wormholes are invisible to cryptography. B tunnels RREQ to M. M broadcasts. T sees M as neighbor of B. MAC confirms integrity, but topology is fake. Neighbor Discovery helps only if it measures latency/distance."
```

#### 详细的答题注意事项（文字版）：

**1. 关于 Q3 (RREP 有效性) 的重坑：**
*   **方向性问题：** 题目给出的 RREP 列表是 `{T,M,J,G,B,S}`。无论这代表从 T 回 S 的路径，还是 S 到 T 的累积路径，你必须检查这个顺序是否符合 **Source Routing（源路由）** 的要求。
*   **MAC 的覆盖范围：** RREP 中的 MAC 是 `MACKS,T`。这意味着只有 S 能验证它。中间节点无法验证 RREP 的完整性（除非有额外的机制），这可能导致中间节点被篡改。
*   **字段缺失：** 标准的 SRP 回复通常需要包含原来的 `QID` 或 `QSEQ` 来防止重放。题目中虽然包含了 `QSEQ`，但你需要确认这是否足够抵抗重放攻击（通常 QSEQ 需要维护状态，而 QID 更好匹配）。

**2. 关于 Q4 (Rushing Attack / 抢先攻击)：**
*   这是一个经典的攻击方式。题目提到“Node rebroadcasts **once**. Otherwise ignores”.
*   **坑：** 如果 E 听到 S 的 RREQ，迅速伪造一个垃圾包或者只是快速转发（甚至提升功率），抢在合法节点（如 B）之前到达 D、C。那么 D、C 会记录下 `(QID, Source)` 并丢弃随后到达的合法 RREQ。这样 E 实际上“切断”了其他合法路径的发现能力。解决方案通常涉及稍微延迟转发或处理多个 RREQ。

**3. 关于 Q5 (公钥与密钥建立)：**
*   **同时性 (Simultaneously)：** 这里的要求是在 Route Discovery 的同一个报文交互中完成密钥协商。
*   **Transport vs Agreement：**
    *   *Transport:* S 生成一个对称密钥 $K$，用 T 的公钥加密 $Enc_{PK_T}(K)$ 放在 RREQ 里？（注意 RREQ 是广播，这样效率很低且容易被 DoS）。或者 T 生成 $K$，用 S 的公钥加密放在 RREP 里？（这是常见的做法）。
    *   *Agreement (DH):* S 发送 $g^x$，T 回复 $g^y$。
*   **坑 - MITM：** 仅仅交换公钥组件是不够的。攻击者可以替换掉 $g^x$。**必须**使用 S 和 T 的私钥对这些组件进行**签名**。题目明确提到了 Certificates，所以必须在协议步骤中体现出签名的过程。
*   **确认密钥成功：** 如果是 Transport（T 发给 S），S 收到 RREP 解密即得到。T 如何确认 S 得到了？通常需要 S 再发一个确认（ACK）或随后的数据包使用该密钥加密。

**4. 关于 Q6 & Q8 (隐藏节点与虫洞/共谋)：**
*   **Q6 (单点作恶)：** 如果 B 只是从 RREQ 的 Accumulated Route List 中删掉自己。T 收到 RREQ，计算 MAC。如果 MAC 只包含 S 和 T 的共享密钥内容，无法校验中间路径的真实性（SRP 实际上通过中间节点把自己 ID 加入并最终由 S 验证或 T 验证来工作）。如果 T 计算 MAC 时包含接收到的 List，那么 MAC 是有效的。S 收到 RREP 后，看到路径是 `{S,E...}`。但实际上物理包经过了 B。这会导致 S 发送数据时下一跳地址错误（MAC层地址需要是B）。
    *   *关键点：* 路由协议层（IP层）和 MAC层（链路层）的不一致。
*   **Q8 (共谋/虫洞)：** 这是最高级的攻击之一。B 和 M 之间有一条私密的高速通道（带外或者通过封装）。B 收到 RREQ，不广播，直接传给 M。M 在 T 附近重播。T 认为 M 的上游就是 B。
    *   *坑：* 这种攻击在纯加密层面几乎无解，因为所有签名的内容都没有变。防御需要基于物理特性的检查（如 Q7 的邻居发现，如果包含距离/时间测量）或封包卫士（Packet Leashes）。如果 Q7 只是简单的 Hello 握手，无法防止虫洞攻击。

**5. 关于 Q9 (Link State vs SRP 的不相交路径)：**
*   **Link State (链路状态)：** 既然只要 LSA 泛洪成功，每个节点都有全网地图，S 可以计算出**所有**可能的路径，包括所有不相交路径。
*   **SRP (反应式)：** SRP 由于“每个节点只转发一次 RREQ”的特性，通常只能发现**第一条**到达的路径，或者极少数几条（如果协议允许转发不同路径的副本）。大量潜在的路径因为中间节点已处理过相同 QID 而被丢弃。
*   **坑：** 因此，LS 协议比 SRP 更能找到所有不相交路径。回答时要抓住“转发抑制”这个机制对拓扑发现能力的限制。

你的回答应当体现出对 **Cryptographic binding (加密绑定)**、**Topology fidelity (拓扑保真度)** 和 **Physical constraints (物理约束)** 的深刻理解。


----
这是一个非常经典的关于无线自组网（MANET）安全路由协议（SRP/DSR）的综合练习题。它涵盖了从基本的协议操作到高级攻击（如抢先攻击、虫洞攻击）的分析。

以下是针对每个问题的详细解答：

---

### 1. RREQ 的传播 (RREQ Propagation)

**解答：**

当源节点 S 想要与目标节点 T 通信但没有路由时，它会发起路由发现。

1.  **S 的动作：** S 构造一个 RREQ 数据包。
    *   内容包括：`(RREQ, QSEQ, QID, Source=S, Destination=T, Path_List=[], MAC)`。
    *   S 将其广播给它的物理邻居（根据题目设定，S 知道邻居是 A, B, C）。
2.  **中间节点的动作（以 S -> A -> D -> H -> T 为例）：**
    *   **节点 A** 收到 RREQ。
        *   检查 `(S, QID)` 是否已存在于其“最近见过的请求表”中。如果是新的，A 处理它。
        *   A 将自己的 ID 添加到路径列表中：`Path_List=[A]`。
        *   A 重新广播该数据包。
    *   **节点 D** 收到来自 A 的 RREQ。
        *   检查重复性。
        *   添加 ID：`Path_List=[A, D]`。
        *   重新广播。
    *   **节点 H** 收到来自 D 的 RREQ。
        *   检查重复性。
        *   添加 ID：`Path_List=[A, D, H]`。
        *   重新广播。
3.  **T 的接收：** T 收到来自 H 的 RREQ，路径列表显示为 `[A, D, H]`。此时 T 获取到了从 S 到 T 的完整路径信息。

---

### 2. 安全邻居发现 (Secure Neighbor Discovery, SND)

**解答：**

安全邻居发现是路由协议的基础，它确保节点声称的邻居不仅在物理通信范围内，而且是经过身份验证的真实节点。

*   **机制：** 通常通过周期性地广播“Hello”消息来实现。
*   **安全性：** 为了防止欺骗（例如，一个远处的节点假装在附近），节点必须对其 Hello 消息进行**签名**（使用私钥）或附加**MAC**（如果有共享密钥）。
*   **过程：**
    1.  节点 A 广播 `Hello, ID=A, Nonce, Signature`。
    2.  节点 B 收到后，验证签名。如果验证通过，且信号强度/往返时间符合物理邻近特征，B 将 A 记录为“可信邻居”。
*   **目的：** 这建立了一个本地的拓扑视图（Neighbor Table），防止外部攻击者轻易通过重放远处信号来伪造连接。

---

### 3. RREP 的有效性与验证 (RREP Validity & Validation)

**解答：**

*   **有效性判断：**
    *   题目给出的字段：`QSEQ`, `{T,M,J,G,B,S}`, `MACKS,T ({T,M,J,G,B,S},QSEQ)`。
    *   这是**有效**的。
    *   **路径方向：** 路径列表 `{T,M,J,G,B,S}` 清晰地描述了从 T 回到 S 的每一跳（或者说是 S 到 T 的反向路径）。在源路由协议（如 DSR/SRP）中，RREP 携带完整路径是标准做法。
    *   **MAC：** 使用了 S 和 T 的共享密钥 $K_{S,T}$ 对路径和序列号进行了认证。这保证了端到端的完整性。
*   **RREP 如何传回 S：**
    *   由于是源路由，RREP 数据包本身这就包含了路由 `{T,M,J,G,B,S}`。
    *   T 将包发给 M -> M 查表发给 J -> J 发给 G ... -> 最后到达 S。每个中间节点只需根据包头中的路径转发，无需查找本地路由表。
*   **S 如何验证：**
    1.  S 收到 RREP 后，提取 `QSEQ` 和路径列表 `{T,M,J,G,B,S}`。
    2.  S 检查本地是否有对应的未完成的 RREQ 请求（通过 `QSEQ` 或对应的 `QID`）。
    3.  S 使用预共享密钥 $K_{S,T}$ 计算收到的数据的 MAC 值：$Calculated\_MAC = MAC(K_{S,T}, \{Path, QSEQ\})$。
    4.  S 将计算出的 MAC 与包中的 MAC 进行比对。如果一致，说明该路径确实由 T 确认过，且未被传输过程中的恶意节点**篡改**（注意：这只能证明 T 签了名，不能证明路径不仅是 T 以为的那样，见后续攻击）。

---

### 4. 抢先攻击 (Rushing Attack)

**解答：**

*   **能否阻止：** **能 (Yes)**。攻击者 E **可以**阻止合法 RREQ。
*   **原因（机制）：**
    *   SRP/DSR 规定每个节点对每个 `(S, QID)` 只重播**一次**。后续收到的具有相同 ID 的 RREQ 会被视为重复包而丢弃。
    *   **攻击过程：** 攻击者 E 在听到 S 的 RREQ 后，迅速以极高的处理速度或大功率发射，将 RREQ 转发给邻居 D, C, G。
    *   **结果：** D, C, G 首先收到来自 E 的 RREQ，记录下该 RREQ 已处理。当通过合法路径（如经过 A 或 B）的 RREQ 稍后到达时，D, C, G 会认为这是重复包并将其丢弃。
*   **修复方法：**
    *   **随机延迟：** 节点在收到 RREQ 后不立即转发，而是等待一个随机时间。并在等待期间收集多个副本，从中选择质量最好或经过验证的邻居发送的副本进行转发，而不是简单地“先到先得”。

---

### 5. 基于公钥的 SRP 修改 (Public Key Variant)

**解答：**

如果没有预共享密钥，我们需要使用公钥证书来实现身份验证和密钥协商。

*   **协议设计：**
    *   **假设：** S 有 $(PuK_S, PrK_S)$，T 有 $(PuK_T, PrK_T)$。双方都信任 CA。
    *   **目标：** 在发现路由的同时建立共享会话密钥 $K_{session}$。
    *   **RREQ (S -> T)：**
        *   S 生成一个随机的**密钥分量**（如 Diffie-Hellman 的 $g^x$）或直接生成临时密钥（如果是密钥传输模式）。
        *   消息内容：`RREQ, QID, [Path], Cert_S, g^x, SIG_S(RREQ fields)`。
        *   这里 S 必须对 RREQ 的不可变部分进行**数字签名**，以证明身份。
    *   **RREP (T -> S)：**
        *   T 收到 RREQ，验证 $Cert_S$ 和签名。
        *   T 生成自己的密钥分量 $g^y$，计算出共享密钥 $K = (g^x)^y$。
        *   消息内容：`RREP, [Path], Cert_T, g^y, MAC_K(Path), SIG_T(RREP fields)`。
        *   T 对回复进行签名，并用新生成的 $K$ 对路径做 MAC 验证（类似于原版 SRP）。
*   **安全性分析：**
    *   安全性等同，因为证书提供了可信的身份绑定。中间人无法伪造 S 或 T 的签名，也无法在没有私钥的情况下篡改 Diffie-Hellman 交换而不被发现。
*   **确认密钥获取：**
    *   **T 确认 S 得到了密钥：** 此时 T 还**不能**确认。T 发出 RREP 后，只有当 S 使用该密钥 $K$ 发送了第一个数据包（Data Packet）或专门的 ACK 包，并正确加密/MAC 了数据，T 收到并验证成功后，才能确认 S 成功计算出了密钥。

---

### 6. 节点隐藏攻击 (Node Hiding Attack)

**解答：**

*   **攻击方式：** 真实路径是 S-E-B-G...，攻击者 B 收到 RREQ 后，转发给 G，但**不将自己的 ID 添加到路径列表中**。
*   **结果：**
    *   G 收到包，看到上一个记录的节点是 E，于是添加 G。RREQ 到达 T 时，路径显示为 `{S, E, G, ...}`。
    *   T 签署并返回 RREP。S 收到 RREP，认为路径是 S-E-G...
*   **影响：**
    *   S 会试图将数据包发送给 E，并指示 E 的下一跳是 G。
    *   但在物理层，E 的下一跳实际上必须是 B 才能到达 G。如果 E 按照源路由头部的 MAC 地址寻址（即下一跳 MAC 设为 G 的 MAC），数据包可能会丢失（如果 G 在 E 的射频范围外）。
    *   **B 的动机：** 避免被列入路由列表可以节省自身资源（不用处理被明确指定发给它的数据），或者逃避特定的监测机制，同时又能通过操纵流量（如在转发时丢包）来进行隐蔽的拒绝服务。

---

### 7. 邻居发现对隐藏攻击的防御

**解答：**

*   **攻击是否被阻止：** **是 (Yes)**（在很大程度上）。
*   **原因：**
    *   如果 S, E, G 等节点都运行安全邻居发现协议，它们清楚地知道谁是物理邻居。
    *   在上面的例子中，如果 B 隐藏了自己，路径变成了 `... E - G ...`。
    *   当 T 发回 RREP 给 S 时，或者当数据流开始传输时，S 会指示 E 将包发给 G。
    *   **检查点 1：** E 在收到源路由指令“下一跳是 G”时，会查阅自己的**邻居表**。E 会发现 G **不在**邻居表中（因为中间隔了个 B）。E 应该报错（Route Error）并丢弃该路径。
    *   **检查点 2：** T 在收到 RREQ 时，如果能通过某种方式验证拓扑（较难），也可以发现异常。但主要依靠中间节点（如 E）验证下一跳（G）是否真的是邻居。

---

### 8. 共谋/虫洞攻击 (Collusion/Wormhole Attack)

**解答：**

*   **攻击概述：** B 和 M 串通。他们之间建立了一条可以在逻辑上忽略跳数的“高速通道”（Wormhole），例如通过一根长网线、定向长距离无线链路或带外信道。
*   **攻击过程：**
    1.  B（在 S 附近）收到 RREQ。
    2.  B **不**通过正常广播转发，而是将 RREQ 封装，通过虫洞直接传给 M（在 T 附近）。
    3.  M 解封 RREQ，将其作为来自 B 的广播重新播放。
    4.  T 收到 RREQ，看到路径列表为 `[S, B, M]`（假设 B 和 M 把自己加上去了）。
    5.  T 计算 MAC，因为 B 和 M 是合法节点且正确操作了密钥/ID，**MAC 验证通过**。
*   **规避控制：** SRP 的 MAC 只能验证路径列表中的 ID 是否被篡改，无法验证这些节点在物理上是否真的相邻。虫洞让远处节点在“协议层”看起来像邻居。
*   **影响：** S 和 T 认为 {S, B, M, T} 是一条极短的优质路径。所有流量都会被引导经过 B 和 M。攻击者可以完全控制流量（分析、选择性丢包、断网）。
*   **防御：** 标准 SRP **无法**阻止此攻击。需要物理层防御（如 Packet Leashes，在包中加入 GPS 坐标或极其严格的时间戳来检测传输距离是否异常）。

---

### 9. 附加题：复杂度与多路径 (Complexity & Disjoint Paths)

**解答：**

1.  **消息复杂度：**
    *   **RREQ:** 是全网泛洪。每个节点广播一次。复杂度为 $O(N)$（$N$ 为网络节点数）或更准确地说是 $O(Edges)$。
    *   **RREP:** 单播返回。长度为路径跳数 $L$。
    *   **总复杂度：** $O(N)$。

2.  **多路径与不相交路径：**
    *   **SRP/DSR 的局限性：** 默认情况下，SRP 倾向于只发现**一条**路径（最快到达的那条）。因为中间节点会丢弃后续到达的具有相同 `QID` 的 RREQ（哪怕它们来自完全不同的路径）。
    *   **Link State (链路状态) vs SRP:** 在之前的练习中提到的**安全链路状态协议**更有可能提供所有可用的不相交路径。因为在链路状态协议中，拓扑信息（LSA）会在全网泛洪，S 最终会拥有**完整的网络地图**，可以通过算法（如 Dijkstra）计算出所有的不相交路径。而 SRP 受限于“抑制重复广播”机制，丢失了拓扑细节。

3.  **如果重传 2 个副本：**
    *   如果中间节点允许转发同一 `QID` 的 RREQ **两次**（来自不同邻居），那么 T 收到多条不同路径 RREQ 的概率大大增加。这能显著提高发现不相交路径（Disjoint Paths）的能力，但也增加了网络拥塞和开销。

4.  **利用移动性增强安全：**
    *   **思路：** 节点在移动中物理相遇时，可以进行面对面的密钥交换或证书交换（类似于 PGP 的 Web of Trust 或延迟容忍网络 DTN 的概念）。
    *   **如何增强：**
        *   当 S 和 T 最终需要通信时，他们可能已经通过之前的偶尔相遇直接交换了公钥，或者通过可信的共同朋友交换了公钥。
        *   这减少了对在线 CA 的依赖（去中心化）。
        *   可以建立一个**分布式信任图**。在路由发现时，如果路径上的节点都是在这个“相遇信任链”中的熟人，S 会更信任该路径。