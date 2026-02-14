### Exercise 5 Secure inter-domain routing (练习 5：安全域间路由)

Original Text: Exercise 5 Secure inter-domain routing (65 points + 20 extra credit) Consider the (fictitious) snapshot of inter-domain connectivity of Autonomous Systems (ASes) in Fig. 2 and assume that all implement a combination of RPKI and Route Origin Authorization (ROA) and BGP security (BGPsec). Let one Relying Party (RP) have the following list of Validated ROA Payloads (VRPs) in its list (recall: tuples (AS number, ROA prefix, prefix length, maxlength). Without maxlength in an ROA, the AS is authorised to announce only the specified prefix.

1. (AS512,130.229.0.0,16,24)
2. (AS312,130.28.0.0,16,−)

中文翻译： 练习 5 安全域间路由 (65 分 + 20 分额外加分) 考虑图 2 中自治系统 (AS) 域间连接的（虚构）快照，假设所有 AS 都实现了资源公钥基础设施 (RPKI)、路由源授权 (ROA) 和 BGP 安全 (BGPsec) 的组合。 假设一个依赖方 (RP) 在其列表中拥有以下已验证 ROA 载荷 (VRP) 列表（回顾：元组 (AS 号, ROA 前缀, 前缀长度, 最大长度)）。如果在 ROA 中没有指定最大长度，则该 AS 仅被授权宣告指定的前缀。

1. (AS512, 130.229.0.0, 16, 24)
2. (AS312, 130.28.0.0, 16, −)

---

Original Text: 8 AS 312 AS 512 Figure 2: Interconnected AS topology. The signing routers’ public keys are distributed to all ASs with the help of the RPKI. For simplicity, you can assume a single router per AS and use the AS identifier.

中文翻译： 8 AS 312 AS 512 图 2：互连的 AS 拓扑结构。 签名路由器的公钥在 RPKI 的帮助下分发给所有 AS。为了简单起见，你可以假设每个 AS 有一个路由器并使用 AS 标识符。

---

#### Question 1

Original Text:

1. (30 pt) Please consider AS431 receiving the following BGP announcements: • 130.28.0.0/22, AS-PATH: AS312 • 130.229.0.0/22, AS-PATH: AS512 • 130.229.0.0/23, AS-PATH: AS234 Please explain if each of the above, based only on RPKI and ROAs, is valid, invalid or unknown?

中文翻译：

1. (30 分) 请考虑 AS431 收到以下 BGP 宣告： • 130.28.0.0/22, AS-PATH: AS312 • 130.229.0.0/22, AS-PATH: AS512 • 130.229.0.0/23, AS-PATH: AS234 请解释基于 RPKI 和 ROA，上述每一个宣告是有效的 (valid)、无效的 (invalid) 还是未知的 (unknown)？

---

#### Question 2

Original Text: 2. (35 pt) Please consider now BGPsec, acting together with RPKI. (a) (5 pt) Please explain which cryptographic protection BGPsec adds to the above announcements and write the message format for one valid announcement. (b) (10 pt) Then, assume the announcement propagates through AS431 to AS123 to AS213. Please write the successive messages by BGPsec. (c) (10 pt) Assuming AS123 is adversarial, please explain if it can remove AS431 from the AS-PATH before forwarding the announcement to AS213. (d) (10 pt) Can AS123 forward the announcement without removing anything but without adding itself in the AS-PATH?

中文翻译： 2. (35 分) 请考虑现在 BGPsec 与 RPKI 协同工作。 (a) (5 分) 请解释 BGPsec 为上述宣告增加了哪些加密保护，并写出一个有效宣告的消息格式。 (b) (10 分) 然后，假设宣告经由 AS431 传播到 AS123 再到 AS213。请写出 BGPsec 的后续消息。 (c) (10 分) 假设 AS123 是恶意的，请解释它在将宣告转发给 AS213 之前，是否可以从 AS-PATH 中移除 AS431。 (d) (10 分) AS123 能否在不移除任何内容但不将自己添加到 AS-PATH 中的情况下转发宣告？

---

#### Question 3 (Extra Credit)

Original Text: 3. (extra credit 20 pt) Now consider AS123 being adversarial and colluding with AS231: they have a AS123-AS231 tunnel (communicating directly, in an encrypted manner, e.g., over the AS234−AS213 path). Let AS231 tunnel the original announcement of 130.229.0.0/20 (by AS512) to AS123, which in turn forwards it to AS213 (with all the BGPsec cryptographic protection). Please write the messages and explain how AS213 validates this announcement. What if the tunnel is not encrypted?

中文翻译： 3. (额外加分 20 分) 现在考虑 AS123 是恶意的并且与 AS231 勾结：它们有一个 AS123-AS231 隧道（以加密方式直接通信，例如，通过 AS234-AS213 路径）。让 AS231 将 130.229.0.0/20 的原始宣告（由 AS512 发出）通过隧道传给 AS123，AS123 再将其转发给 AS213（带有所有 BGPsec 加密保护）。请写出消息并解释 AS213 如何验证此宣告。如果隧道未加密会怎样？

---

### Answer of exercise 5 (练习 5 的答案)

#### Answer 1

Original Text:

1. The BGP announcement can be validated as follows: • Although it is covered by VRP number 2 It is invalid, becuase it is too specific. • It is valid as it matches with VRP number 1 with regard to maxlength. • Although the IP prefix is matched by VRP number 1, the ASN is different, so it is invalid.

中文翻译：

1. BGP 宣告的验证如下： • 虽然它被 VRP 编号 2 覆盖，但它是无效的 (invalid)，因为它太具体了（注：/22 比 /16 更长，超出了限制）。 • 它是有效的 (valid)，因为它在最大长度方面与 VRP 编号 1 匹配。 • 虽然 IP 前缀与 VRP 编号 1 匹配，但 ASN 不同，所以它是无效的 (invalid)。

---

#### Answer 2

Original Text: 2. The answer are as follows: (a) BGPSec adds digital signature over the AS-PATH, meaning each AS would sign the next authorized AS to propagate the announcement: AS512: BGP1 ←{130.229.0.0/22,{AS431,AS512}},{130.229.0.0/22,{AS431,AS512}}$\text{Sign}_{\text{PrivAS512}}$ AS512→AS431: BGP1 (b) AS431: BGP2 ←{130.229.0.0/22,AS123,BGP1},{130.229.0.0/22,AS123,BGP1}$\text{Sign}_{\text{PrivAS431}}$ AS431→AS123: BGP2 AS123: BGP3 ←{130.229.0.0/22,AS213,BGP2},{130.229.0.0/22,AS213,BGP2}$\text{Sign}_{\text{PrivAS123}}$ AS123→AS213: BGP3 (c) No, as the next hop is signed, this attack is not possible. (d) No, as the next hop is signed, it should add itself, otherwise the next AS inline is not legitimate to propagate the announcement.

中文翻译： 2. 答案如下： (a) BGPSec 在 AS-PATH 上添加了数字签名，这意味着每个 AS 都会对下一个被授权传播宣告的 AS 进行签名： AS512: BGP1 ← {130.229.0.0/22, {AS431, AS512}}, 用AS512私钥签名({130.229.0.0/22, {AS431, AS512}}) AS512→AS431: BGP1 (b) AS431: BGP2 ← {130.229.0.0/22, AS123, BGP1}, 用AS431私钥签名({130.229.0.0/22, AS123, BGP1}) AS431→AS123: BGP2 AS123: BGP3 ← {130.229.0.0/22, AS213, BGP2}, 用AS123私钥签名({130.229.0.0/22, AS213, BGP2}) AS123→AS213: BGP3 (c) 不能，因为下一跳已被签名，这种攻击是不可能的。 (d) 不能，因为下一跳已被签名，它应该添加自己，否则链路中的下一个 AS 不具备传播宣告的合法性。

---

#### Answer 3

Original Text: 3. The original announcement of AS512 to AS231 is as follows: AS512: BGP1 ←{130.229.0.0/22,{AS231,AS512}},{130.229.0.0/22,{AS231,AS512}}$\text{Sign}_{\text{PrivAS512}}$ AS512→AS231: BGP1 Given that AS231 is authorized by AS512 to propagate its anouncement in the network, it can simply sign AS123 as the next hop, and send the BGP announcement through the tunnel: AS231: BGP2 ←{130.229.0.0/22,AS123,BGP1},{130.229.0.0/22,AS123,BGP1}$\text{Sign}_{\text{PrivAS231}}$ AS231→AS123: BGP2 With this announcement, AS123 then signs AS213 as the next hop and introduces this ASPATH in the network. AS123: BGP3 ←{130.229.0.0/22,AS213,BGP2},{130.229.0.0/22,AS213,BGP2}$\text{Sign}_{\text{PrivAS123}}$ AS123→AS213: BGP3 Since all the signature are valid, AS123 would accept this path as valid with respect to RPKI and ROA and BGP security (BGPsec). Even if the tunel is not encrypted, the ASes would not realise the attack, as it would be considered the communication between the colluding nodes and not the BGP announcement in the network.

中文翻译： 3. AS512 发给 AS231 的原始宣告如下： AS512: BGP1 ← {130.229.0.0/22, {AS231, AS512}}, 用AS512私钥签名({130.229.0.0/22, {AS231, AS512}}) AS512→AS231: BGP1 鉴于 AS231 被 AS512 授权在网络中传播其宣告，它可以简单地将 AS123 签名为下一跳，并通过隧道发送 BGP 宣告： AS231: BGP2 ← {130.229.0.0/22, AS123, BGP1}, 用AS231私钥签名({130.229.0.0/22, AS123, BGP1}) AS231→AS123: BGP2 有了这个宣告，AS123 随后将 AS213 签名为下一跳，并在网络中引入此 ASPATH。 AS123: BGP3 ← {130.229.0.0/22, AS213, BGP2}, 用AS123私钥签名({130.229.0.0/22, AS213, BGP2}) AS123→AS213: BGP3 因为所有的签名都是有效的，AS123（_注：原文此处应指接收方 AS213_）将根据 RPKI、ROA 和 BGP 安全 (BGPsec) 接受此路径为有效。 即使隧道未加密，AS 们也不会意识到攻击，因为它会被视为勾结节点之间的通信，而不是网络中的 BGP 宣告。

思考了 40.699 秒

请你详细的告诉我上一条中的qs2，的b，为什么是这样，另外告诉我这个宣告的是否有一个请求方？然后他在添加路径的时候具体是怎么添加的？

思考了 30.806 秒

5 条记忆1 个工具

这是一个非常深入且关键的问题。要理解练习 5 中 Question 2(b) 的答案，我们需要先纠正一个关于 BGP（边界网关协议）如何工作的核心概念，然后深入探讨 BGPsec（BGP Security） 的验证机制。

以下是详细的拆解：

### 1. 这个宣告是否有一个“请求方”？

答案是：没有。

- BGP 是“推送”（Push）协议，而不是“请求-响应”（Pull）协议。
    - 在 BGP 中，路由宣告是由拥有 IP 地址段（Prefix）的源头 AS（Origin AS）发起的。
    - 在图 5 的例子中，AS512 拥有 `130.229.0.0/22` 这个网段。它想让全世界都知道：“如果你要访问这个 IP 段，请把流量发给我。”
    - 所以，AS512 会主动向它的邻居（如 AS431）发送“宣告”（Announcement/Advertisement）。它不需要邻居来“请求”这个路由。
    - 邻居收到后，如果觉得这条路好走，就会继续向 _它的_ 邻居（如 AS123）转发这个宣告。

总结： 这是一个由 AS512 发起的广播过程，目的是告诉大家“我在哪里”，而不是某个具体的请求方在问路。

---

### 2. 为什么 Q2(b) 的消息格式是那个样子？

Question 2(b) 问的是：当宣告从 AS431 传到 AS123，再传到 AS213 时，BGPsec 的消息长什么样。

#### BGPsec 的核心逻辑：锁定“下一跳”（Next Hop）

普通 BGP 只是把 AS 号加到列表里（容易被篡改）。BGPsec 则要求：每个 AS 在转发路由时，必须用自己的私钥“指定”下一个接收者是谁。

这就像接力跑：

1. AS512 说：“我是源头，我把棒子传给 AS431。”（AS512 签名）
2. AS431 接到棒子，说：“我确实从 AS512 那里拿到的，现在我把棒子传给 AS123。”（AS431 签名）
3. AS123 接到棒子，说：“我确实从 AS431 那里拿到的，现在我把棒子传给 AS213。”（AS123 签名）

#### 详细步骤解析（对应答案）

让我们看看答案中的公式是如何体现这个逻辑的。

步骤 1：AS431 发给 AS123

在此之前，AS431 已经收到了来自 AS512 的 `BGP1` 消息。 现在 AS431 要把路由传给 AS123。

消息 `BGP2` 的构成： BGP2←{130.229.0.0/22⏟IP 前缀,AS123⏟目标 AS,BGP1⏟旧的证据},SignatureAS431BGP2←{IP 前缀130.229.0.0/22​​,目标 ASAS123​​,旧的证据BGP1​​},SignatureAS431​

- AS123 (Target AS): 这是最关键的一点。AS431 在消息里写明：“我是发给 AS123 的”。
    - _为什么重要？_ 如果 AS431 实际上发给了 AS888，但 AS888 想假装自己是 AS123，它做不到，因为签名里写死了接受者是 AS123。
- SignPrivAS431: AS431 用私钥对（前缀 + 目标 AS123 + 收到的旧消息 BGP1）进行签名。
- 结果: AS123 收到后，用 AS431 的公钥解密签名，确认两件事：
    1. 这条消息确实是 AS431 发的。
    2. AS431 确实是想发给我（AS123）的。

步骤 2：AS123 发给 AS213

现在 AS123 收到了 `BGP2`，决定转发给 AS213。

消息 `BGP3` 的构成： BGP3←{130.229.0.0/22⏟IP 前缀,AS213⏟新的目标,BGP2⏟旧的证据},SignatureAS123BGP3←{IP 前缀130.229.0.0/22​​,新的目标AS213​​,旧的证据BGP2​​},SignatureAS123​

- 包含 BGP2: 消息必须由外向内层层包裹（或者说链式连接）。AS123 把刚才收到的完整证据 `BGP2` 打包进去。
- AS213: 指定新的接收者。
- SignPrivAS123: AS123 用自己的私钥签名。

---

### 3. 他在添加路径的时候具体是怎么添加的？

在 BGPsec 中，由于涉及加密签名，路径的添加不是简单的文本拼接，而是一个洋葱式（Layered）或链式（Chained）的过程。

我们可以把它想象成写保证书：

1. AS512 (源头):
    
    - 写下：“我拥有 IP 130...，我授权 AS431 传播它。”
    - 动作：盖上 AS512 的章（签名）。
    - 当前路径: `[AS512]` (且指定下一跳为 431)
2. AS431 (中间人):
    
    - 收到 AS512 的保证书。
    - 写下：“我收到 AS512 的保证书（附在后面），现在我授权 AS123 传播它。”
    - 动作：把 AS512 的带章保证书拿在手里，加上自己的一段话，然后在最外面盖上 AS431 的章。
    - 当前路径: `[AS512, AS431]` (且指定下一跳为 123)
3. AS123 (中间人):
    
    - 收到 AS431 的一叠文件（包含 431 的章和 512 的章）。
    - 写下：“我收到了 AS431 的保证书（附在后面），现在我授权 AS213 传播它。”
    - 动作：把那叠文件再包一层，在最外面盖上 AS123 的章。
    - 当前路径: `[AS512, AS431, AS123]` (且指定下一跳为 213)

具体的数据结构变化：

在实际的 BGPsec 协议包中，这通常表现为两个属性的增长：

1. AS Path 列表: `AS512, AS431, AS123` （这是明文列表，供路由器快速查看路由长度）。
2. Signature Block (签名块):
    - `Sig1` (由 512 签: Prefix + Target=431)
    - `Sig2` (由 431 签: Sig1 + Target=123)
    - `Sig3` (由 123 签: Sig2 + Target=213)

验证过程（也是接收方 AS213 必须做的）：

当 AS213 收到 `BGP3` 时，它必须从外向内（或从头到尾）验证：

1. 用 123 的公钥验证 `Sig3`：确定是 123 发给 213 的。
2. 拥有 `Sig3` 后解出 `Sig2`，用 431 的公钥验证 `Sig2`：确定是 431 发给 123 的。
3. 拥有 `Sig2` 后解出 `Sig1`，用 512 的公钥验证 `Sig1`：确定是 512 发给 431 的。

这就是为什么答案中写成 `BGP3 = {..., BGP2}, Sign` 的形式，它强调了这种嵌套包含的关系。

思考了 30.806 秒

也就是说，这个BGP1，其实是一个消息的整体就代表了两个节点的连接对吗，然后ip前缀指的是要去的那个as的ip？然后这个信息解密的时候，相当于是从终点到起点的对吗

思考了 22.942 秒

5 条记忆1 个工具

你对这几个概念的直觉非常敏锐，但有几个关键的细节需要修正，特别是关于“IP前缀”的定义和“解密”的方向。

我们来逐一澄清：

### 1. 关于“IP 前缀”（Prefix）：这是货物，不是卡车

> 你的理解： “ip前缀指的是要去的那个as的ip？” 纠正： 不对。

- IP 前缀（例如 130.229.0.0/22）：这是最终目的地里的资源。它是 AS512 因为“拥有”这块网段所以向大家广播的“地址范围”。
    - 想象一下：AS512 是一个“省”（比如浙江省）。`130.229.0.0/22` 是这个省里的“门牌号范围”。
    - AS512 广播说：“所有寄往 `130.229...` 这个范围的信，请交给我。”
- AS 的 IP / 路由器的 IP：这是建立连接用的接口 IP（卡车司机的电话号码）。BGP 报文里确实有 Next Hop IP，但这里的 Prefix 是指路由的内容（Payload）。

总结： 所有的 AS（431, 123, 213）都在传递一个信息——“怎么去 `130.229.0.0/22` 这个网段”。

---

### 2. 关于“BGP1”：它代表“一段授权”，而不只是“连接”

> 你的理解： “BGP1，其实是一个消息的整体就代表了两个节点的连接对吗？” 修正： 基本正确，但更准确地说，它代表了“上一跳对下一跳的授权”。

在 BGPsec 中，`BGP1` 是一个累积的证据包。

- BGP1 的含义： “我是 AS512（源头），我声明这块地（IP prefix）是我的，并且我授权 AS431 帮我传话。”
- 物理连接： AS512 和 AS431 之间确实有物理连接，但 BGP1 这个消息证明的是信任链的开启。

当 AS431 生成 `BGP2` 时，它把 `BGP1` 包在里面，变成了：

- BGP2 的含义： “我是 AS431。你看里面的 `BGP1` 证明 AS512 信任我。现在，我授权 AS123 帮我传话。”

所以，每一个新的 BGP 消息（1 -> 2 -> 3）都代表路径上延伸出的新的一环。

---

### 3. 关于“解密/验证”顺序：是从终点往回溯源吗？

> 你的理解： “这个信息解密的时候，相当于是从终点到起点的对吗？” 修正： 完全正确！（准确地说是“验证签名”，不是解密内容，但逻辑是一样的）。

这叫做“洋葱剥皮”或者“回溯验证”。

假设你是 AS213（接收链的最后一方），你收到了来自 AS123 的 `BGP3`。你的验证逻辑如下：

第一层（最外层）：验证你的邻居（AS123）

- 看： 谁发给我的？是 AS123。
- 验： 用 AS123 的公钥 验证最外层的签名。
- 问： AS123 说的下一跳（Target）是我（AS213）吗？
- 结论： 是的，AS123 确实发给了我。

第二层（中间层）：验证邻居的邻居（AS431）

- 看： AS123 是从谁那拿到的？AS123 说它收到了 `BGP2`（来自 AS431）。
- 验： 用 AS431 的公钥 验证 `BGP2` 里的签名。
- 问： AS431 授权的下一跳是 AS123 吗？
- 结论： 是的，AS431 确实传给了 AS123。

第三层（核心层）：验证源头（AS512）

- 看： AS431 是即使从谁那拿到的？`BGP1`（来自 AS512）。
- 验： 用 AS512 的公钥 验证 `BGP1`。
- 问： AS512 授权的下一跳是 AS431 吗？AS512 有资格宣告这个 IP 前缀吗（查 ROA）？
- 结论： 是的，源头合法，且授权给了 AS431。

只有当这就好像倒着查： `AS213 <---(验证)--- AS123 <---(验证)--- AS431 <---(验证)--- AS512`

### 总结图示

为了方便你记忆，可以看这个流程：

1. 方向 (数据流): AS512 (源) ---> AS431 ---> AS123 ---> AS213 (你)
2. 内容 (IP Prefix): 大家都拿着写着 "AS512的地盘" 的包裹。
3. 验证 (信任流): AS213 (你) 必须往回看，先查 AS123 的章，再查 AS431 的章，最后查 AS512 的章。

思考了 22.942 秒

然后我想知道，就是这个： AS512: BGP1 ←{130.229.0.0/22,{AS431,AS512}},{130.229.0.0/22,{AS431,AS512}}$\text{Sign}_{\text{PrivAS512}}$ AS512→AS431: BGP1 是一个完整的数据包对吧，就是包括了明文的路径信息？然后这个每一条宣告的右侧，都是路径的起点？谁宣告，谁就在右边？

思考了 28.443 秒

5 条记忆1 个工具

你的理解非常到位！完全正确。

让我们把这个公式像“解剖”手术一样拆开来看，你马上就会明白为什么是这样排列的。

### 1. 这是一个完整的数据包吗？

是的，这是一个完整的“包裹”。

公式： BGP1←{130...,{AS431,AS512}}⏟明文数据（信的内容）,{130...,{AS431,AS512}}Sign⏟加密签名（信封上的火漆印）BGP1←明文数据（信的内容）{130...,{AS431,AS512}}​​,加密签名（信封上的火漆印）{130...,{AS431,AS512}}Sign​​

这个数据包包含了路由器处理所需的所有部分：

1. 明文部分（Payload）： 告诉路由器“我在发什么 IP”以及“路径是怎样的”。路由器如果不验证签名，光看这部分也能转发（虽然不安全）。
2. 签名部分（Signature）： 用来证明前面的明文没有被篡改。

---

### 2. 关于左右位置：谁在右边？谁是起点？

> 你的理解： “每一条宣告的右侧，都是路径的起点？谁宣告，谁就在右边？” 答案： 完全正确。这遵循 BGP 的“堆栈”逻辑。

在 BGP（以及这道题的表示法）中，路径列表（AS Path）通常是从左向右增长的，或者你可以理解为把新的 AS 压入堆栈的顶部（左边）。

让我们看这道题里的表示 `{AS431, AS512}`：

- 右边 (`AS512`)： 是 源头 (Origin) 或 当前签字的人 (Signer)。
- 左边 (`AS431`)： 是 目标 (Target) 或 下一跳 (Next Hop)。

#### 为什么这么设计？（生活中的类比）

想象这一摞盘子，或者写推荐信的过程：

第一步：AS512 (源头) 发出

- AS512 拿出一个盘子，写上“我是 AS512”。
- 他要把盘子递给 AS431，所以他在上面盖个章“给 AS431”。
- 列表状态： `431, 512` (431 在最上面/左边，512 在下面/右边)。
- 谁在右边？ 512（起点/老大哥）。

第二步：AS431 (中间人) 转发

- AS431 接过盘子。
- 他要转发给 AS123。他不会去改 512 写的东西。
- 他把自己加到列表的最前面（左边）。
- 列表状态： `123, 431, 512`。
- 谁在右边？ 还是 512（起点不动）。谁在左边？ 最新的接收者（123）。

#### 对应到题目中的 BGPsec 签名逻辑

在题目里的 `{AS431, AS512}` 这一小块：

1. AS512 是这个动作的发起者（Signer）。它用私钥签名。
2. AS431 是被指定的“下一位选手”。

所以当你读这个列表时：

- 往右看： 寻找历史、寻找源头（Origin）。
- 往左看： 寻找当下、寻找去向（Next Hop）。

总结：

- 最右侧 = 树根/源头/爷爷 (AS512)
- 最左侧 = 树梢/最新跳/孙子 (AS431)

这个结构确保了无论路径多长，源头总是固定在最右边（或堆栈底部），方便路由器一眼看出“这货原本是谁发的”。

思考了 28.443 秒

Upload File

T工作目录已锁定

A工具

A

M推理

Google: Gemini 3 Pro Preview

2%