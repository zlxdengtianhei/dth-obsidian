以下是中英文逐段对照翻译，以及对题目中潜在陷阱和答题注意事项的详细分析。

---

### 第一部分：中英逐段对照翻译

**Exercise 1 Symmetric key security protocols (80 points + 30 points extra credit)**
**练习 1：对称密钥安全协议（80分 + 30分 附加分）**

Consider a diverse Internet of Things (IoT) environment. Users carry portable devices, e.g., smartphones or tablets, with wireless networking capabilities, notably IEEE 802.11 (call this Radio 1), IEEE 802.15.4 (Radio 2), and BlueTooth Low Energy (Radio 3). Moreover, consider embedded devices with sensing and actuating capabilities operating with transceivers of type Radio 2 or Radio 3; wireless access points (APs) operating with transceivers of type Radio 1; and an authentication server, S, at the back-end, connected via a wireline link (or subnetwork or the Internet) to the APs (see Fig. 1).
考虑一个多样化的物联网 (IoT) 环境。用户携带具有无线网络功能的便携式设备，例如智能手机或平板电脑，主要使用 IEEE 802.11（称为 Radio 1）、IEEE 802.15.4（Radio 2）和低功耗蓝牙（Radio 3）。此外，还有具备传感和致动功能的嵌入式设备，使用 Radio 2 或 Radio 3 类型的收发器；无线接入点 (AP)，使用 Radio 1 类型的收发器；以及位于后端的认证服务器 S，通过有线链路（或子网或互联网）连接到 AP（见图1）。

Each user device, A, embedded device, E, and access point, AP, shares a symmetric key with the server S, stored in the device at the time of bootstrapping (i.e., before it is handed to the user or deployed).
每个用户设备 A、嵌入式设备 E 和接入点 AP 都与服务器 S 共享一个对称密钥，该密钥在设备初始化/引导时（即交付给用户或部署之前）已存储在设备中。

Let a user device, A, and an access point, AP, with no a priori association, get within communication range. The system needs a simple method for users to securely communicate over the wireless medium, based on a key shared by each A and each AP. It is important that each user device has its own key, distinct from the ones of the other user devices connected to the specific AP. Assume that A sends a security association establishment request message to the AP but until the association establishment is completed A is not granted network access, i.e., it is not allowed by AP to access any other entity over the Internet.
假设一个用户设备 A 和一个接入点 AP 在彼此没有预先关联的情况下进入了通信范围。系统需要一种简单的方法，让用户能够基于 A 和 AP 之间共享的密钥，在无线介质上安全地进行通信。重要的是，每个用户设备都必须拥有自己的密钥，且该密钥要与连接到该特定 AP 的其他用户设备的密钥区分开来。假设 A 向 AP 发送安全关联建立请求消息，但在关联建立完成之前，A 不会被授予网络访问权限，即 AP 不允许 A 访问互联网上的任何其他实体。

Design a protocol that leverages the A-S and AP-S trust (security associations) and results in A and AP having the sought key.
设计一个利用 A-S 信任关系和 AP-S 信任关系（即各自的安全关联）的协议，使 A 和 AP 最终获得所需的共享密钥。

Assume that A initiates the protocol, moreover, assume a single identifier for each device, e.g., a data link/medium access address and assume those known to S for all devices that are bootstrapped/associated with it. For simplicity, assume that there is no need that the cryptographic key itself be derived from contributions of more than one involved party. Finally, you can assume that A is only loosely synchronized with AP (and S) before establishing a security association with AP.
假设 A 发起该协议，此外，假设每个设备有一个唯一标识符，例如数据链路/介质访问控制（MAC）地址，并且假设 S 知道所有与其关联/引导过的设备的这些标识符。为了简化，假设不需要从多个参与方的贡献中推导出加密密钥本身（即不需要复杂的密钥协商，密钥可以由单方生成）。最后，你可以假设在与 AP 建立安全关联之前，A 与 AP（以及 S）之间只有松散的时间同步。

Explain concisely why your protocol achieves the following:
简明扼要地解释为何你的协议实现了以下几点：

*   No unregistered device A (not bootstrapped/associated with S) can obtain a shared key with AP.
    没有未注册的设备 A（即未与 S 进行初始化/关联的设备）能够获得与 AP 的共享密钥。
*   No attacker, M, overhearing the A-AP exchange (in both or either direction(s)), can modify at will the established (with the help of S) key by A and AP.
    没有攻击者 M，即使监听了 A-AP 的交换（无论是双向还是单向），能够随意修改 A 和 AP 建立（在 S 帮助下）的密钥。
*   No attacker, M, as the aforementioned one, can replay messages from older executions of the protocol (possibly its own earlier protocol with AP) and mislead A.
    没有攻击者 M（如前所述），能够重放旧的协议执行消息（可能是它自己早期与 AP 的协议交互）来误导 A。
*   More generally, no attacker, M, as the one in the previous question, can act as a rogue AP (not associated with S) and mislead legitimate devices A to establish connections with it.
    更一般地，没有攻击者 M（如前一问题所述），能够充当流氓 AP（未与 S 关联）并误导合法设备 A 与其建立连接。

Does your protocol provide protection against an attacker M that is connected on the same wireline network as AP and S? For the third sub-case above for M, consider the ’wireline’ attacker trying to pose as an AP to S. Please give a brief justification and respond only with respect to your protocol.
你的协议是否能防范连接在 AP 和 S 同一有线网络上的攻击者 M？针对上述 M 的第三种情况，考虑“有线”攻击者试图向 S 伪装成一个 AP。请仅针对你的协议给出简要理由并回答。

If not already done in your first design, please add one more feature to your protocol: a confirmation message exchange (handshake) that allows A and AP to confirm that indeed the other party has exactly the obtained key.
如果你的初步设计中尚未包含，请在协议中增加一个功能：一个确认消息交换（握手），允许 A 和 AP 确认对方确实拥有该获取的密钥。

Does your protocol provide protection against a compromised embedded device E? Please give a brief justification.
你的协议是否能防范被攻陷的嵌入式设备 E？请给出简要理由。

Can the same compromised embedded device E cause a Denial of Service DoS for the A-AP-S communication
同一个被攻陷的嵌入式设备 E 能否对 A-AP-S 通信造成拒绝服务（DoS）攻击？

Now consider an embedded device E; the user with device A comes within range of E (over Radio 2 or Radio 3), while she/it has access to the Internet over Radio 1. E provides specific measurements A is interested in. How can A and E establish a security association exactly in this setup? Recall that E does not have any connection to rest of the network, other than its own radio. Provide your protocol.
现在考虑一个嵌入式设备 E；携带设备 A 的用户在通过 Radio 1 接入互联网的同时，进入了 E 的通信范围（通过 Radio 2 或 Radio 3）。E 提供 A 感兴趣的特定测量数据。在这种特定设置下，A 和 E 如何建立安全关联？请记住，E 除了自身的无线电外，没有连接到网络的其他部分。请提供你的协议。

Assume E is queried by A and responds by sending messages containing each the ten most recent measurements (assume they are taken every second). Thus, it can transmit a message every 10 seconds. A needs to verify the authenticity of each message and the integrity of a sequence of such messages (over a period of one minute). Moreover, data must be kept confidential. Please design and present your protocol, stating your assumptions.
假设 A 查询 E，E 通过发送包含最近十次测量的消息进行响应（假设每秒测量一次）。因此，它可以每10秒发送一条消息。A 需要验证每条消息的真实性以及一系列此类消息（在一分钟的时段内）的完整性。此外，数据必须保密。请设计并展示你的协议，并说明你的假设。

**Extra credit: 30 points**
**附加分：30分**

Next, assume A moves a bit, establishes an association (symmetric key) with another embedded device F (as it did with E, no need to repeat any details of the protocol). E and F are neighbors, i.e., they can communicate directly. Although they are not supposed to in general (note: mostly, bidirectional portable device-to-embedded device communication). Now, A wishes to “configure” F and E so that they pass measurements from one to another when A is away (out of range) and store them; for fault tolerance and load balancing. A can then query either node and obtain the sought data.
接下来，假设 A 稍微移动了一下，与另一个嵌入式设备 F 建立了关联（对称密钥）（就像它与 E 做的那样，无需重复协议细节）。E 和 F 是邻居，即它们可以直接通信。虽然一般情况下它们不应该通信（注：主要是便携式设备与嵌入式设备的双向通信）。现在，A 希望“配置”F 和 E，以便当 A 不在（超出范围）时，它们可以将测量数据相互传递并存储；以实现容错和负载均衡。然后，A 可以查询任一节点并获取所需数据。

Describe a protocol, possibly with a single message that A can send to E and F, such that A sets up the necessary information to both of them and:
描述一个协议，可能包含 A 发送给 E 和 F 的单条消息，使得 A 为它们两者设置必要的信息，并且：

*   E learns the identity (or medium access control address) of F and vice-versa
    E 得知 F 的身份（或 MAC 地址），反之亦然。
*   E can authenticate messages F passes to it and vice-versa, preventing replays and detecting message losses (“gaps”).
    E 可以验证 F 传递给它的消息，反之亦然，以防止重放并检测消息丢失（“间隙”）。
*   A can authenticate messages originating from E but stored by F (and the other way around)
    A 可以验证源自 E 但由 F 存储的消息（反之亦然）。

Next, discuss if your protocol allows A to detect whether E skipped passing on messages to F for storing (or the other way around, the setting is symmetric). You can assume the periodic measurements as in question 8, with local and peer storage (e.g., F takes measurements and then stores them locally in the form of messages if A is not around to ask for them; also, it passes them to E, its peer). Can F make A believe that E has not passed all measurements in messages, although it does?
接下来，讨论你的协议是否允许 A 检测 E 遗漏了将消息传递给 F 进行存储（或反之，设置是对称的）。你可以假设如问题 8 中的定期测量，具备本地和对等存储（例如， 如果 A 不在附近询问，F 进行测量并将其以消息形式存储在本地；同时，它也将其传递给它的对等节点 E）。F 能否让 A 相信 E 没有通过消息传递所有测量数据，尽管 E 实际上已经传了？

---

### 第二部分：题目陷阱与答题注意事项分析

这个题目设计得非常经典，典型的基于可信第三方（Trusted Third Party, TTP）的密钥分发协议设计（类似 Kerberos 或 Needham-Schroeder 协议的变体）。以下是你需要特别注意的“坑”和答题要点：

#### 1. 初始条件与网络拓扑的限制 (The Topology Constraint)
*   **A 和 S 不能直接通信**：这是一个巨大的陷阱。题目明确指出 A 在建立关联之前**无法访问网络**（"until the association establishment is completed A is not granted network access"）。
*   **注意事项**：你的协议流程不能写成 `A -> S`。必须是 `A -> AP -> S`。AP 必须充当“中继（Relay）”角色。A 发送给 S 的所有数据包都必须封装在发给 AP 的包里，由 AP 转发给 S。

#### 2. 时间同步的陷阱 (Loose Synchronization)
*   **坑：** 题目说 "Assume that A is only loosely synchronized"。
*   **注意事项：** **千万不要依赖严格的时间戳（Timestamps）来防止重放攻击**。你需要使用 **Nonce（随机数）**。A 在第一步生成一个随机数 $N_A$，并在 S 的回复中检查这个 $N_A$ 是否存在，以确保消息是新鲜的（Freshness）而不是重放的。

#### 3. 密钥生成的简化 (Key Generation)
*   题目提到 "no need that the cryptographic key itself be derived from contributions of more than one involved party"。
*   **答题策略：** 不需要使用 Diffie-Hellman (DH) 交换。最简单的方法是由服务器 **S 生成会话密钥 $K_{session}$**，然后分别用 $K_{AS}$ 和 $K_{APS}$ 加密后发给 A 和 AP。不要把协议设计得过于复杂。

#### 4. 安全目标的具体实现 (Security Requirements)
答题时需要显式地将协议的每一步与题目要求的安全目标对应起来：
*   **Rogue AP (流氓 AP) 防护：** A 如何知道与其通信的 AP 是合法的？答案在于 AP 必须证明它能解密 S 发来的消息（或者 S 必须在给 A 的加密包里包含 AP 的 ID）。
*   **Wireline Attacker (有线攻击者) 防护：** 这是一个比较隐蔽的考点。AP 和 S 之间的链路虽然是有线的，但如果没有加密保护，攻击者可以在线上截获或篡改。你的协议应该确保 S 发给 AP 的包是加密和认证的（Authenticated Encryption），或者至少 S 发给 A 的部分（通过 AP 转发）是端到端加密的（用 $K_{AS}$ 加密），中间的攻击者或者假 AP 无法篡改这部分内容。

#### 5. 确认握手 (Key Confirmation)
*   题目要求 "confirmation message exchange"。
*   **注意事项：** 仅仅收到密钥是不够的。协议最后必须有 `A -> AP` 和 `AP -> A` 的消息交互，使用新生成的会话密钥加密或计算 MAC（消息认证码）来证明双方都成功拿到了钥匙。

#### 6. 嵌入式设备 E 的场景 (Offline E)
*   **场景变化：** A 有网，E 没网。
*   **策略：** 这里 A 充当了网关。A 想要验证 E，或者和 E 建立密钥。因为 E 和 S 共享密钥 $K_{ES}$，A 需要充当中间人，将 E 的挑战（Challenge）转发给 S，或者 S 提前给 A 一个“Ticket”（票据）用来访问 E。
*   **坑：** 只有 E 产生的数据 A 才能读（Confidentiality），且 A 需要验证数据确实来自 E。最合理的流程是 A 请求 S 生成一个 A 与 E 的会话密钥，S 将其加密在一个 E 能解密的 Ticket 中发给 A，A 再转发给 E（类似 Kerberos）。

#### 7. 序列完整性 (Sequence Integrity) - 1分钟10条消息
*   **需求：** 每10秒发一条，共6条，需要验证顺序和防丢包。
*   **答题策略：** 必须引入**序列号 (Sequence Numbers)** 或者 **哈希链 (Hash Chain)**。单纯的消息认证码 (MAC) 只能防篡改，不能防删除或乱序。每一条消息都必须包含序列号，并且整个序列需要某种形式的关联。

#### 8. 附加题：A 配置 E 和 F
*   **难点：** 单条消息配置，且 E 和 F 互不信任但需要交换数据。
*   **思路：** A 已经分别与 E 和 F 建立了密钥。A 生成一个 E 和 F 之间的共享密钥 $K_{EF}$。A 构造一条消息，里面包含：
    1.  用 $K_{AE}$ 加密的 $\{K_{EF}, ID_F, ...\}$
    2.  用 $K_{AF}$ 加密的 $\{K_{EF}, ID_E, ...\}$
    *   A 把这个包广播给它俩，或者分别发送。
*   **数据验证：** E 产生的数据存到 F。A 以后来取数据时，如果仅仅信任 F，F 可能会篡 改 E 的数据。因此，E 产生数据时必须用 **E 的密钥（或者 A-E 密钥）进行签名或 MAC**。F 只是存储这团加密/签名过的数据。A 拿到数据后，验证 E 的签名。F 无法伪造 E 的数据。

#### 9. 附加题最后的陷阱：Detecting Skipped Messages
*   **问题：** F 是否声称 E 没发数据，但其实 E 发了？
*   **分析：** 这是一个不可抵赖性问题。如果 E 发给 F 的消息中包含严密的序列号，并且 A 读取 E 的日志时能看到 "我只要发了第 N 条"，而 A 在 F 那里找不到第 N 条，那么 F 就撒谎了。关键在于 E 和 F 之间交互时是否有“回执 (Ack)”。如果协议设计为 E 发给 F，F 必须签一个“我收到了”的回执给 E 存着。如果 F 赖账，E 可以拿出 F 的签名回执打脸。如果没有回执机制，F 确实可以赖账说“我没收到”。

### 总结建议
在回答协议设计题时，建议使用标准的密码学符号：
*   $A, AP, S$: 实体
*   $N_A$: A生成的Nonce
*   $\{M\}_K$: 用密钥 K 加密消息 M
*   $MAC(K, M)$: 消息认证码
*   $||$: 连接符号

并且画出清晰的时序图（Message Sequence Chart）。逻辑的严密性比复杂的算法更重要。


---
这里是针对该习题的完整解答，包含基础部分（80分）和附加部分（30分）的详细设计与分析。

### 练习 1：对称密钥安全协议设计 (Exercise 1)

#### 1. 协议设计 (A-AP 互信与密钥分发)

**设计思路：**
由于 $A$ 在未建立安全关联前无法直接访问互联网，必须通过 $AP$ 进行中继。这类似于 Kerberos 协议的一个变体。$S$ 作为可信第三方 (TTP)，负责生成会话密钥 $K_{Sess}$。

**符号定义：**
*   $ID_X$：实体 X 的唯一标识符。
*   $N_X$：实体 X 生成的随机数 (Nonce)，用于防重放。
*   $K_{XY}$：X 和 Y 之间的长期共享对称密钥。
*   $K_{Sess}$：S 生成的 A 和 AP 之间的临时会话密钥。
*   $\{M\}_K$：使用密钥 K 对消息 M 进行加密（并包含完整性校验，假设为 AEAD 模式）。

**协议流程：**

1.  **A Initiates:**
    $A \rightarrow AP: ID_A, N_A$
    *(A 告诉 AP 我是谁，并给出一个随机数用于验证后续响应的新鲜度)*

2.  **AP Requests Key:**
    $AP \rightarrow S: ID_{AP}, \{ID_A, N_A, N_{AP}\}_{K_{APS}}$
    *(AP 向 S 请求与 A 通信。AP 使用与 S 的共享密钥加密请求，包含 A 的 Nonce 和自己的 Nonce $N_{AP}$)*

3.  **S Generates & Responds:**
    S 生成会话密钥 $K_{Sess}$。
    S 构建发给 AP 的消息：
    $S \rightarrow AP: \{ID_A, N_{AP}, K_{Sess}, Ticket_A\}_{K_{APS}}$
    其中，$Ticket_A = \{K_{Sess}, ID_{AP}, N_A, Lifetime\}_{K_{AS}}$
    *(S 验证 AP 的请求，生成密钥。外层包给 AP，包含验活的 $N_{AP}$ 和会话密钥；内层 Ticket 是给 A 的，AP 无法解密)*

4.  **AP Forwards:**
    AP 解密 S 的消息，验证 $N_{AP}$（确保是针对刚才请求的回应），获取 $K_{Sess}$。
    $AP \rightarrow A: Ticket_A$
    *(AP 将票据转发给 A)*

5.  **A Verifies:**
    A 解密 $Ticket_A$，验证 $N_A$（确保消息新鲜），验证 $ID_{AP}$（确保是和预期的 AP 建立连接），获取 $K_{Sess}$。

6.  **Key Confirmation (Handshake):**
    （题目后文要求的功能，在此一并列出）
    $A \rightarrow AP: \{N'_A\}_{K_{Sess}}$
    $AP \rightarrow A: \{N'_A - 1\}_{K_{Sess}}$
    *(双方证明自己拥有 $K_{Sess}$)*

---

#### 2. 安全性分析简述

*   **No unregistered device A can obtain a shared key (防止未注册设备):**
    未注册的设备 A 没有与 S 共享的有效密钥 $K_{AS}$。在第 5 步中，它无法解密 $Ticket_A$ 来获取 $K_{Sess}$。

*   **No attacker M can modify the key (防止篡改):**
    所有的关键信息（特别是 $K_{Sess}$）都在传输过程中被加密保护（$\{...\}_{K_{APS}}$ 和 $\{...\}_{K_{AS}}$）。如果攻击者修改密文，合法的解密或完整性检查（MAC）将会失败，协议终止。

*   **No attacker M can replay messages (防止重放):**
    *   **对 A 的保护：** A 在第 1 步生成 $N_A$，并在第 5 步解密的 $Ticket_A$ 中检查 $N_A$。旧消息中的 Nonce 不匹配，会被丢弃。
    *   **对 AP 的保护：** AP 在第 2 步生成 $N_{AP}$，并在第 4 步检查 S 的回复。

*   **No attacker M can act as a rogue AP (防止流氓 AP):**
    如果一个流氓 AP（拥有 $ID_{Rogue}, K_{Rogue-S}$）试图欺骗 A。它必须向 S 请求票据。S 会在 $Ticket_A$ 中封装该 AP 的真实 ID（$ID_{Rogue}$）。当 A 解密票据时，会发现 $ID_{ticket} (Rogue) \neq ID_{expected} (AP)$，从而拒绝连接。如果流氓 AP 试图重放合法 AP 的旧票据，由于 $N_A$ 不匹配，攻击也会失败。

*   **Wireline Attacker Protection (有线攻击者):**
    **问题：** 协议是否防范连接在 AP 和 S 之间试图伪装成 AP 的有线攻击者？
    **回答：** **是。** 在第 2 步中，AP 发送的消息是使用 $K_{APS}$ 加密的。攻击者没有 $K_{APS}$，无法伪造合法的密钥请求给 S（S 解密失败会丢弃）。同理，攻击者也无法解密 S 发回的包含 $K_{Sess}$ 的响应。

---

#### 3. 补充功能与嵌入式设备分析

**Key Confirmation (密钥确认):**
已在协议步骤 6 中包含。A 发送用 $K_{Sess}$ 加密的挑战，AP 正确解密并修改返回，证明双方持有相同密钥。

**Protection against compromised Embedded device E (被攻陷的 E):**
**回答：** **是。**
**理由：** 题目假设所有密钥彼此独立且由 S 分发。设备 E 只拥有 $K_{ES}$。它不知道 $K_{AS}$ 或 $K_{APS}$。因此，E 无法解密 A 和 S 之间或 AP 和 S 之间的任何通信，也无法伪造 A 或 AP 的身份。

**Can E cause DoS? (E 能否造成 DoS):**
**回答：** **可以。**
**理由：** 虽然 E 无法破坏加密协议的逻辑（Cryptographic DoS），但 E 是一个无线发射设备。它可以不断发送无线信号进行**物理层干扰 (Jamming)**，阻塞 Radio 2 或 Radio 3 频段，或者如果它与 A 在同一信道，通过发送垃圾数据包耗尽 AP 或 A 的处理资源。

---

#### 4. A 与 Offline Embedded Device (E) 的安全关联

**场景：** A 有网，E 无网。A 需要作为网关协助建立连接。

**协议流程：**

1.  $A \rightarrow E$: Hello Request (Query)
2.  $E \rightarrow A$: $ID_E, N_E$
    *(E 给出身份和随机数)*
3.  $A \rightarrow S$ (via AP): $ID_A, \{ID_E, N_E, N_A\}_{K_{AS}}$
    *(A 请求与 E 通信，包含 E 的挑战 $N_E$)*
4.  $S \rightarrow A$: $\{ID_E, K_{AE}, N_A, Ticket_E\}_{K_{AS}}$
    其中 $Ticket_E = \{ID_A, K_{AE}, N_E\}_{K_{ES}}$
    *(S 验证 A，生成 $K_{AE}$。发给 A 的包里包含自证 $N_A$ 和给 E 的票据)*
5.  $A \rightarrow E$: $Ticket_E$, Authenticator $\{N_E\}_{K_{AE}}$ (可选，用于确认)
6.  $E$ Verify: 解密 $Ticket_E$，检查 $N_E$，获得 $K_{AE}$。

---

#### 5. 测量数据传输协议 (Measurements)

**需求：** 每10秒一条消息，验证真实性、机密性、序列完整性。

**假设：**
*   使用 **Encrypt-then-MAC** 或 **AEAD (如 AES-GCM)** 模式。
*   使用单调递增的序列号 (SeqNum) $SN$。
*   会话开始时 $SN$ 初始化为 0。

**协议消息结构 (E -> A):**

对于第 $i$ 条消息 ($i=1...6$):
$$Msg_i = \text{Header} || \text{Ciphertext} || \text{Tag}$$

1.  **Payload Construct:** $P_i = \text{Measurement}_i || SN=i$
2.  **Encryption:** $C_i = Encrypt(K_{AE}, P_i)$
3.  **Authentication:** $Tag_i = MAC(K_{AE}, \text{Header} || C_i)$
    *(Header 可包含 $ID_E$)*

**A 的验证逻辑：**
1.  解密消息 $C_i$。
2.  验证 MAC。
3.  **完整性检查：** A 维护一个期望计数器 $Next\_SN$。接收到的 $SN$ 必须等于 $Next\_SN$。如果 $SN > Next\_SN$，说明中间有丢包（Gap）；如果 $SN < Next\_SN$，说明是重放或乱序。
4.  **时序检查：** 结合本地计时器，确保并未在短时间内收到大量重放包。

---

### 附加题 (Extra Credit: 30 points)

**场景：** A 配置 E 和 F 互相传递消息。

#### 1. 配置协议 (Configuration Protocol)

A 生成一个共享密钥 $K_{EF}$。A 发送两条消息（或广播一条复合消息）：

*   **Message 1 (A -> E):** $\{K_{EF}, ID_F, \text{Instruction}\}_{K_{AE}}$
*   **Message 2 (A -> F):** $\{K_{EF}, ID_E, \text{Instruction}\}_{K_{AF}}$

**结果：** E 和 F 都获得了 $K_{EF}$ 和对方的身份，且知道这一指令来自 A (因为由 $K_{AE}/K_{AF}$ 加密)。

#### 2. E 和 F 通信与数据认证 (Data Authentication)

**目标：**
*   E 认证 F（反之亦然）。
*   A 认证**源自 E** 但由 F 存储的数据。

**协议设计：**
当 E 需要发送测量数据 $M$ 给 F 存储时，E 构建以下数据包：

1.  **Origin Proof (给 A 看):** $Tag_{Origin} = MAC(K_{AE}, M || SN_E)$
    *(使用 A 和 E 的密钥 $K_{AE}$ 进行签名，包含序列号。F 无法伪造此标记)*
2.  **Transmission Payload:** $Payload = M || SN_E || Tag_{Origin}$
3.  **Transport Security (给 F 看):** $Packet = \{Payload\}_{K_{EF}}$ 和/或 $MAC(K_{EF}, Payload)$

**数据流：**
*   $E \rightarrow F$: $Packet$
*   F 解密验证（使用 $K_{EF}$），确认来自 E。F 存储 $Payload$。
*   当 A 稍后向 F 查询时，F 发送 $Payload$ 给 A。
*   A 计算 $MAC(K_{AE}, M || SN_E)$ 并与 $Tag_{Origin}$ 对比。

#### 3. 检测消息遗漏 (Cheating Detection)

**问题：** F 能否让 A 相信 E 没有传数据（尽管 E 传了）？

**分析：**
是的，如果仅凭上述协议，F 可以选择性地丢弃收到的消息。例如 E 发送了 序列号 1, 2, 3。F 收到所有，但只存了 1 和 3。
当 A 读取数据时，A 看到 1 和 3。
*   A 通过检查 $Tag_{Origin}$ 里的 $SN_E$，会发现序列变成了 1 -> 3，**检测到了 Gap (间隙)**。
*   **A 知道数据丢失了。**

**判定责任 (Extra Discussion):**
*   **Can F make A believe E didn't pass it? (F 能甩锅吗?)**
    如果 E 仅仅发送数据而没有来自 F 的不可抵赖的回执 (Non-repudiation receipt)，F 可以声称 "E 从来没发过 #2"。A 无法区分 "无线链路丢包/E 未发送" 和 "F 恶意删除"。
*   **然而**，如果题目问的是“F 能否伪造一种状态，让 A 以为 E 的发送序列本就是连续的（掩盖丢失的事实）？”
    **回答：不能。** 因为 $Tag_{Origin}$ 中包含了被 $K_{AE}$ 保护的单调递增序列号 (Sequence Number)。F 无法修改 $SN$（比如把 #3 改成 \#2），也无法伪造 E 的 MAC。因此，A **一定**能检测到数据丢失。
*   至于能一并检测出 **E 是否跳过了发送**：
    如果 E 的逻辑是每秒采样并计数，$SN$ 代表时间戳。如果 E 确实没发（比如 E 死机了），A 看到的下一个有效包 $SN$ 依然会跳跃（基于时间）或者 E 会继续计数。但这里的关键是 **A-Origin Authentication** 锁死了序列号。F 只能删除，不能修改顺序或伪造连续性。A 会看到 "Gap"，从而知道 F 没有提供完整的数据流（无论责任在谁，各方数据不一致被检测到了）。