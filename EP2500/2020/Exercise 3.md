这是一份涉及公钥基础设施（PKI）、跨域认证、端到端安全以及隐私保护的综合性练习题。

以下是题目的中英对照翻译，随后是对题目中潜在“坑点”和答题注意事项的深度分析。

### 第一部分：中英对照翻译

**Exercise 3 Secure & private crowd-sensing (60 points + 40 points extra credit)**
**练习 3：安全且隐私的群智感知（60 分 + 40 分附加分）**

**Consider a similar setup as that in Exercise 1 and Exercise 2 as illustrated in Fig. 2. The user-portable devices, $A$, and a subset of the embedded devices that are equally well equipped as $A$s, can use regularly public key cryptography. We term the special-purpose embedded devices gateways, $EG$. $A$ and $EG$ are registered each with one Certification Authority, CA. In general, $EG$ are static and $A$ mobile. Let us also assume there are $CA1$, $CA2$, and $CA3$, each serving nodes in one domain respectively. Finally, there is a data aggregation server, $D$; users carrying $A$s and owners of $EG$ agree, at will, to contribute data collected from embedded devices $E_a, E_b, ..., E_z$, and possibly $A$ and $EG$ devices.**
考虑与图 2 所示的练习 1 和练习 2 类似的设置。用户便携设备 $A$，以及一部分计算能力与 $A$ 相当的嵌入式设备，可以常规地使用公钥密码学。我们将这些专用的嵌入式设备称为网关，$EG$。$A$ 和 $EG$ 分别在一个证书颁发机构（CA）处注册。通常情况下，$EG$ 是静止的，而 $A$ 是移动的。假设存在 $CA1$、$CA2$ 和 $CA3$，分别服务于不同域中的节点。最后，还有一个数据聚合服务器 $D$；携带 $A$ 的用户和 $EG$ 的所有者同意（自愿地）贡献从嵌入式设备 $E_a, E_b, ..., E_z$ 收集的数据，乃至从 $A$ 和 $EG$ 设备本身收集的数据。

---

**1. Let $A$ be registered with $CA1$ and $EG$ be registered with $CA2$. Assume that, as in Exercise 2, $A$ initiates a protocol to obtain data by $EG$. How can $A$ and $EG$ achieve mutual authentication based on public key primitives? Please do not re-write full protocols based on Exercise 2, but rather explain what additional steps, prior and/or during the protocols, would be needed.**
1. 设 $A$ 注册于 $CA1$，而 $EG$ 注册于 $CA2$。假设如同练习 2 中那样，$A$ 发起一个协议以从 $EG$ 获取数据。$A$ 和 $EG$ 如何基于公钥原语实现**双向认证**？请不要重写基于练习 2 的完整协议，而是解释在协议之前和/或期间需要哪些**额外的步骤**。

---

**2. Can an $EG$ instantiate a policy that allows differentiating the level of access (e.g., no access, low priority, high priority) for $A_a, A_b, ..., A_z$? Moreover, how can $D$ differentiate which type of device it obtains the data from? Please discuss briefly.**
2. $EG$ 能否实例化一种策略，以便区分 $A_a, A_b, ..., A_z$ 的访问级别（例如：无访问权、低优先级、高优先级）？此外，$D$ 如何区分它所获得的数据是来自于哪种类型的设备？请简要讨论。

---

**3. Consider again the case of $A$ obtaining data from $EG$, authenticated, with their integrity and confidentiality preserved, over Radio 1. Now consider that the data are measurements that originate from a set of embedded devices, $E_a, E_b, ..., E_z$, that $EG$ directly communicated securely with, over Radio 2 or 3, using symmetric key primitives. Can $A$ corroborate that a measurement originates from a precise embedded $E_a$? In other words, can the measurement origin authenticity and integrity be verified?**
3. 再次考虑 $A$ 通过无线链路 1（Radio 1）从 $EG$ 获取数据的情况，且经过了认证、完整性和机密性保护。现在考虑这些数据是源自一组嵌入式设备 $E_a, E_b, ..., E_z$ 的测量值，$EG$ 此前通过无线链路 2 或 3 使用**对称密钥原语**与这些设备进行了直接的安全通信。$A$ 能否确证某个测量值确实源自某个特定的嵌入式设备 $E_a$？换句话说，测量值的**源认证**（Source/Origin Authentication）和完整性是否可以被验证？

---

**4. If not, what would you change in the design of the system to make this possible? Sketch your solution and explain. If you wish or you need to, you can assume $EG$ is trustworthy.**
4. 如果不能，你会如何改变系统设计使其成为可能？请勾勒你的解决方案并加以解释。如果你希望或需要，你可以假设 $EG$ 是可信的。

---

**5. What would be the approach to address the requirement for the previous question if $EG$ cannot be trusted? Is your approach already addressing this case? Please explain or propose an alternative solution.**
5. 如果 $EG$ **不可信**，针对前一个问题的需求该如何解决？你的（上一题）方案是否已经解决了这种情况？请解释或提出替代方案。

---

**6. Now consider that, indeed, a misbehaving $EG$ is detected to not comply with the system specification, after an attacker compromised it. The system operator installs a new $EG_{-trusted}$. How can nodes $A$, with possibly no prior interaction with this system, be informed and ignore $EG$? What if the attacker extracted the private key of $EG$? Please feel free to leverage $CA2$, the trusted third party $EG$ (and $EG_{-trusted}$) is registered with.**
6. 现在考虑确实检测到一个行为不端的 $EG$ 已经被攻击者攻陷，不再遵守系统规范。系统运营商安装了一个新的 $EG_{-trusted}$。那些可能**之前与该系统没有交互**的节点 $A$，如何被通知并忽略（旧的）$EG$？如果攻击者提取了 $EG$ 的私钥又该怎么办？请随意利用 $CA2$，即 $EG$（和 $EG_{-trusted}$）注册的可信第三方。

---

**7. Extra credit: 40 points**
**7. 附加题：40 分**

**(a) Reconsider the role of $A$ and $EG$: what is the challenge, when $D$ cannot authenticate each measurement but it relies on $A$ or $EG$?**
(a) 重新考虑 $A$ 和 $EG$ 的角色：当 $D$ 无法认证每一个原始测量值，而只能依赖 $A$ 或 $EG$ 时，面临的**挑战**是什么？

**(b) Inversely, what is the drawback of a solution that ensures that each measurement, from $E_a, E_b, ..., E_z$, is directly authenticated by both $A$ first and then $D$?**
(b) 反之，如果采用一种确保来自 $E_a, E_b, ..., E_z$ 的每个测量值都先后被 $A$ 和 $D$ 直接认证的解决方案，其**缺点**是什么？

**(c) What if $CA1$ provides an anonymized (or pseudonumized) certificate that omits $A$’s identity? Can $D$ identify $A$ as the sender of any of the $data_i$, where $i = 1, . . . , 5$ ? Can it link $data_2$ and, for example, $data_5$ to $A$? Please explain briefly why.**
(c) 如果 $CA1$ 提供了一个省略了 $A$ 身份信息的匿名（或伪名）证书呢？$D$ 能否识别出 $A$ 是任何一个 $data_i$（其中 $i = 1, . . . , 5$）的发送者？它能否将 $data_2$ 和（例如）$data_5$ **关联**（link）到 $A$？请简要解释原因。

**(d) What if $CA1$ provides $A$ with five anonymized (or pseudonumized) certificates, $PNYM_1, PNYM_2, ..., PNYM_5$, to $A$? Can $D$ identify $A$ as the sender of any $data_i$, where $i = 1, . . . , 5$? Can it link $data_2$ and, for example, $data_5$ to $A$? Please explain briefly why.**
(d) 如果 $CA1$ 向 $A$ 提供了五个匿名（或伪名）证书，$PNYM_1, PNYM_2, ..., PNYM_5$ 呢？$D$ 能否识别出 $A$ 是任何一个 $data_i$ 的发送者？它能否将 $data_2$ 和（例如）$data_5$ 关联到 $A$？请简要解释原因。

---

### 第二部分：题目分析与答题“坑点”提示

这个练习题主要考察**PKI的实际部署问题**（跨域信任、撤销）和**信任传递问题**（端到端 vs 逐跳安全）。以下是你必须注意的关键点：

#### 1. Q1 的核心陷阱：跨域认证 (Cross-Certification)
*   **表面问题**：怎么双向认证？
*   **深层考点**：题目特意提到 $A \in CA1$ 和 $EG \in CA2$。如果仅仅交换证书，认证**会失败**，因为 $A$ 没有并没有存储 $CA2$ 的公钥，$EG$ 也没有 $CA1$ 的公钥。
*   **必须回答的“额外步骤”**：需要建立 **信任链（Trust Chain）** 或 **交叉认证（Cross-certification）**。
    *   要么存在一个根 CA (Root CA)，$CA1$ 和 $CA2$ 都是其下级；
    *   要么 $CA1$ 和 $CA2$ 互相签发证书（交叉认证）。
    *   在握手前，节点需要获取对方 CA 的证书来验证信任路径。

#### 2. Q3 与 Q5 的逻辑：对称密钥的局限性与信任传递
这里是题目中关于“基于对称密钥的设备”和“基于公钥的网关”混合场景的核心考点。

```infographic list-grid-badge-card
theme list-grid-badge-card
data
  title Q3 Analysis: The Trust Gap
  items
    - label Scenario
      desc Ea → (Sym Key) → EG → (Pub Key) → A
      icon mdi:arrow-right-thin
    - label The Trap
      desc EG verifies Ea via MAC, but A does NOT have the key.
      icon mdi:alert-octagon
    - label Result
      desc A authenticates EG, but cannot verify Ea directly. A must trust EG blindly.
      icon mdi:eye-off
    - label Solution (Q5)
      desc End-to-End security required (Digital Envelope or forwarded MACs).
      icon mdi:shield-lock
```

*   **Q3 (现状分析)**：
    *   $E_a$ 发送消息给 $EG$，用对称密钥 $K_{E_a-EG}$ 加密/MAC。
    *   $EG$ 解密验证后，用自己的私钥签名发给 $A$。
    *   **结论**：$A$ 无法直接验证 $E_a$。$A$ 只能验证“这是 $EG$ 告诉我的”，如果 $EG$ 撒谎，$A$ 无法察觉。
*   **Q5 (不可信的 EG)**：
    *   如果 $EG$ 不可信，你需要**端到端（End-to-End）安全**。
    *   这意味着 $E_a$ 产生的数据必须携带只有 $A$（或 $D$）能验证的凭证。
    *   由于 $E_a$ 只有对称密钥能力，通常需要 $E_a$ 与 $A$（或 $D$）共享密钥，或者使用某种轻量级方案，让 $EG$ 无法篡改原始数据。

#### 3. Q6 的核心：证书撤销列表 (CRL) 与 OCSP
*   **关键词**：“No prior interaction”（无事先交互）。
*   这意味着不能依赖手动配置黑名单。必须通过 PKI 的标准撤销机制。
*   **两个层面的回答**：
    1.  **机制**：$CA2$ 发布 **CRL** (Certificate Revocation List) 或提供 **OCSP** (Online Certificate Status Protocol) 服务。
    2.  **私钥泄露 vs 行为不端**：
        *   如果是“行为不端”，需要 CA 收到举报并在列表里标记该证书失效。
        *   如果是“私钥泄露”，该证书必须立即由于“Key Compromise”原因被撤销，$A$ 在验证证书时必须检查 CA 的最新状态。

#### 4. Q7 (c) 和 (d) 的陷阱：隐私（Privacy）vs 关联性（Linkability）
这是隐私保护里的经典概念区分。

*   **Q7(c) 单一匿名证书**：
    *   **Identifiable (身份可识别吗)?** No. 证书里没有名字（如 "Bob"），只有一个代号。
    *   **Linkable (可关联吗)?** **Yes.** 只要证书是不变的，所有发出的 $data_1, data_2...$ 都带有相同的证书指纹或公钥，$D$ 知道它们来自“同一个匿名用户”。
*   **Q7(d) 多个匿名证书**：
    *   如果 $data_1$ 用 $PNYM_1$，$data_2$ 用 $PNYM_2$...
    *   **Linkable?** **No (理想情况下)**。如果每次发数据换一个证书，$D$ 无法知道这两个数据来自同一个人（除非网络层 IP 泄露，但题目通常只谈应用层/加密层）。
    *   *注意*：如果证书轮换顺序固定，或者上下文信息泄露，仍可能被关联。但在密码学层面，多假名是为了打破关联性。

#### 总结答题策略：
1.  **明确信任锚点**：在 Q1 中不提 Root CA 或 Cross-cert 会扣分。
2.  **区分“跳到跳”与“端到端”**：Q3-Q5 必须明确指出对称密钥无法提供跨节点的源认证，除非密钥共享给终点。
3.  **区分“身份”与“行为”**：Q7 中，匿名保护的是**Who you are**，不可关联性保护的是**What you did (pattern)**。
----
这是针对 **练习 3 (Exercise 3)** 的完整解答。

---

### 练习 3：安全与隐私的群智感知 (Exercise 3)

#### 1. 基于公钥原语的跨域双向认证 (Mutual Authentication across Domains)

**问题核心：** $A$ 和 $EG$ 属于不同的信任域（$CA1$ vs $CA2$）。A 默认只信任 $CA1$，不信任 $CA2$ 签发的证书。

**解决方案：**
要在协议开始前建立信任链（Trust Chain）。不能仅仅交换 A 和 EG 的证书，还需要以下步骤之一：

1.  **交叉认证 (Cross-Certification) 模式：**
    *   $CA1$ 和 $CA2$ 必须预先进行交叉认证。即 $CA1$ 签发一个证书给 $CA2$（证明 $CA1$ 信任 $CA2$），反之亦然。
    *   **协议额外步骤：** 在握手阶段，当 $EG$ 向 $A$ 发送其证书 $Cert_{EG}$ 时，还必须发送由 $CA1$ 签发给 $CA2$ 的交叉证书 $Cert_{CA1 \to CA2}$。
    *   $A$ 的验证路径：$TrustAnchor(CA1) \to Verify(Cert_{CA1 \to CA2}) \to Verify(Cert_{EG})$。

2.  **公共根 (Common Root) 模式：**
    *   假设存在一个根 $RootCA$，它是 $CA1$ 和 $CA2$ 的上级。
    *   **协议额外步骤：** 双方交换证书链。$EG$ 发送 $\{Cert_{EG}, Cert_{CA2}\}$。
    *   $A$ 验证 $Cert_{CA2}$ 是否由根签名，再验证 $EG$。

**认证握手流程：**
类似于 TLS 握手：
1.  $A \to EG$: ClientHello + Random\_A
2.  $EG \to A$: ServerHello + Random\_EG + **Certificate Chain** (包含 $Cert_{EG}$ 和 交叉证书) + Digital Signature (proving possession of Private Key)
3.  $A$ 验证信任链。
4.  $A \to EG$: **Client Certificate Chain** + Digital Signature.
5.  $EG$ 验证信任链。

---

#### 2. 网关的访问控制与服务器的数据区分 (Access Control & Data Differentiation)

*   **EG 实例化策略 (Level of Access):**
    *   **可以。** 这通过在 $A$ 的公钥证书中包含特定的 **属性 (Attributes)** 或 **扩展字段 (Extension Fields)** 来实现。
    *   例如，$CA1$ 在签发证书时，在 `Subject` 或 `Role` 字段中标记该用户的等级（如 `Role: High-Priority` 或 `Role: Guest`）。
    *   $EG$ 在握手验证证书时，解析该字段，并据此决定是否优先处理其请求或分配更多带宽。

*   **D 区分数据来源 (Data Origin Differentiation):**
    *   $D$ 通过验证由于提交数据所使用的 **证书类型** 或 **证书颁发者 (Issuer)** 来区分。
    *   如果数据包是由 $EG$ 签名的（Issuer: CA2），$D$ 知道这来自网关。
    *   如果数据包是由 $A$ 签名的（Issuer: CA1），$D$ 知道这来自用户设备。

---

#### 3. 测量数据的源认证验证 (Origin Authentication of Measurements)

**回答：** **不能 (No)。**

**理由：**
*   这是一个 **逐跳安全 (Hop-by-Hop Security)** 场景。
*   $E_a \to EG$：使用对称密钥 $K_{E_a-EG}$ 保护（MAC 验证）。
*   $EG \to A$：使用 $EG$ 的私钥签名保护。
*   $A$ 只能验证 $EG$ 的签名。这意味着 $A$ 收到的保证是：“$EG$ 声称它从 $E_a$ 收到了这个数据”。
*   $A$ **无法** 密码学地验证数据最初是由 $E_a$ 生成的。如果 $EG$ 被攻陷或恶意篡改数据，$EG$ 可以伪造一个测量值并声称来自 $E_a$，而 $A$ 无法察觉。

---

#### 4. 系统设计改进 (改进为可信架构)

**假设：** $EG$ 是可信的 (Trustworthy)。即便如此，为了让 A 有某种形式的验证，我们需要 $EG$ 提供“背书”。

**解决方案：** **签名的证明/票据 (Signed Attestation)。**
1.  $EG$ 接收来自 $E_a$ 的测量值 $M$ 和 MAC。
2.  $EG$ 验证 MAC 正确。
3.  $EG$ 构建一个新的数据结构：$Metadata = \{ "Source": ID_{Ea}, "Role": "Gateway_Verification_Passed", "Timestamp": T \}$。
4.  $EG$ 将 $Metadata$ 和原始测量值 $M$ 打包，并用自己的私钥 $SK_{EG}$ **签名**。
    $$Packet = M \ || \ Metadata \ || \ Sign(SK_{EG}, M || Metadata)$$
5.  $A$ 接收并验证 $EG$ 的签名。由于 $EG$ 被假定为可信，$A$ 相信 $Metadata$ 中的描述，即数据确实源自 $E_a$。

---

#### 5. 不可信 EG 的解决方案 (Addressing Untrusted EG)

如果 $EG$ 不可信，必须实现 **端到端安全 (End-to-End Security)**。

**挑战：** $E_a$ 只有对称加密能力，不能做数字签名。而 $A$ 只与 $EG$ 有通信，可能不预先知道 $E_a$ 的密钥。

**方案 A：预共享对称密钥 (Pre-shared Keys with A)**
*   如果在部署时，$E_a$ 和未来的用户 $A$ 装载了共享密钥 $K_{AE}$。
*   $E_a$ 发送：$M \ || \ MAC(K_{AE}, M)$。
*   $EG$ 透明转发。$A$ 直接验证 MAC。
*   *(缺点：扩展性差，所有用户都要存所有传感器的钥)*

**方案 B (推荐)：基于服务器 $D$ 的验证 (Server-Mediated Verification)**
*   通常 $E_a$ 和数据服务器 $D$ 会共享长期的对称密钥 $K_{ED}$。
*   $E_a$ 产生数据时计算 $Tag = MAC(K_{ED}, M)$。
*   $EG$ 将 $\{M, Tag\}$ 转发给 $A$。
*   $A$ 无法直接验证 $E_a$，但 $A$ 可以将数据暂存，并在上传给 $D$ 之后，由 $D$ 验证 $Tag$ 并发回一个 **收据 (Receipt)** 给 $A$，确认“刚才那个 $E_a$ 的数据是真的”。

---

#### 6. 证书撤销与恶意 EG 处理 (Revocation)

当 $A$（无预先交互）遇到旧 $EG$ 时，如何知道它已被撤销？

**机制：证书撤销列表 (CRL) 或 OCSP**

1.  **发布：** 当系统运营商发现 $EG$ 被攻陷，$CA2$ 将 $EG$ 的证书序列号加入 **CRL (Certificate Revocation List)**。
2.  **获取：** $A$ 在尝试与 $EG$ 建立连接（握手）时，必须通过 Radio 1 (互联网) 连接到 $CA2$ 的公共服务器下载最新的 CRL，或者向 OCSP 响应器发送查询请求。
3.  **检查：** $A$ 检查 $EG$ 提供的证书是否在黑名单上。
    *   如果是，$A$ 中止连接并忽略该 $EG$。
    *   同时，$A$ 会发现新的 $EG_{-trusted}$（拥有有效证书），并与其建立连接。

**关于私钥泄露：**
如果攻击者提取了私钥，攻击者可以伪装成 $EG$。此时仅靠撤销是不够的，如果 $A$ 处于离线状态（无法获取 CRL），A 会被欺骗。但在本题设置中，$A$ 被假设通过 Radio 1 接入互联网，因此强制要求 **在线状态检查 (Online Status Checking/OCSP)** 是防御私钥泄露导致欺骗的唯一方法。

---

### 7. 附加题：隐私与挑战 (Extra Credit: 40 points)

**(a) D 无法验证源数据的挑战**
当 $D$ 无法直接认证 $E_a$（只能依赖 $A$ 或 $EG$ 转述）时，面临的挑战是 **数据出处 (Data Provenance)** 和 **数据投毒 (Data Poisoning)**。
$A$ 或 $EG$ 可能会篡改数值（例如，为了获得奖励而上传虚假的高质量数据），或者过滤掉不利的数据。$D$ 失去了对物理世界的真实感知，只能盲目信任中间人。

**(b) 逐个测量值端到端认证的缺点**
如果强制要求每个测量值都由 $A$ 和 $D$ 直接认证（例如每个包都带数字签名或端到端 MAC）：
1.  **巨额开销 (High Overhead)：** 嵌入式设备带宽和电量有限，额外的加密头会消耗大量资源。
2.  **密钥管理复杂性：** $D$ 需要检索成千上万个 $E_z$ 的密钥。
3.  **失去了聚合优势：** $EG$ 无法进行数据融合（例如计算平均值来减少传输量），因为一旦 $EG$ 修改数据，端到端的签名/MAC 就会失效。网关退化为单纯的路由器。

**(c) 单一匿名证书 (One Anonymized Certificate)**
*   **Identify A? (识别身份):** **不能。** 证书中没有名字，只有一个假名或随机 ID。
*   **Linkability? (关联性):** **能。**
    *   解释：因为证书是不变的。$data_1$ 由证书 $Cert_{X}$ 签名，$data_5$ 也由 $Cert_{X}$ 签名。
    *   $D$ 可以简单地查看签名者的公钥或证书序列号。如果它们相同，$D$ 就知道这两个数据来自同一个用户。这使得 $D$ 可以通过分析位置和时间轨迹来推断 $A$ 的真实身份（去匿名化攻击）。

**(d) 五个假名证书 (Five Pseudonym Certificates)**
假设 $A$ 分别使用 $PNYM_1 \dots PNYM_5$ 发送 $data_1 \dots data_5$。
*   **Identify A? (识别身份):** **不能。**
*   **Linkability? (关联性):** **不能 (密码学上)。**
    *   解释：$data_2$ 由 $Key_2$ 签名，$data_5$ 由 $Key_5$ 签名。从密码学角度看，这两个公钥没有任何数学关联（假设 CA 生成时是不相关的）。
    *   $D$ 无法证明发送 $data_2$ 的设备和发送 $data_5$ 的设备是同一个。
    *   **注意：** 虽然密码学上不可关联，但如果 $A$ 在短时间内在同一地点连续发送，或者网络层 IP 地址相同，$D$ 仍然可能通过**上下文信息**进行关联，但这超出了纯证书协议的讨论范围。