这是练习的中文逐句对照翻译。为了方便阅读，我将每道题的**问题**与对应的**解答**放在了一起。

---

**Exercise 1 Quick answers (25 points)**
**练习 1 快速问答 (25 分)**

Please read each of the following statements and answer briefly “Right” or “Wrong” and please add a mandatory “because:” two-line justification.
请阅读以下每条陈述，简要回答“正确 (Right)”或“错误 (Wrong)”，并请务必添加一个两行的理由说明“因为 (because)”。

---

**1. (2.5pt) Asymmetric key cryptographic primitives applied on messages, e.g., digital signatures, utilize the same cryptographic key at the sender and receiver.**
**1. (2.5分) 应用于消息的非对称密钥加密原语（例如数字签名），在发送方和接收方使用相同的加密密钥。**

*   **Answer:**
    **解答：**
    *   **Wrong.** Asymmetric key cryptographic primitives use a public key for encryption and a private key for decryption, which are not the same.
        **错误。** 非对称密钥加密原语使用公钥进行加密，使用私钥进行解密，这两者是不一样的。
    *   This is essential for functions like digital signatures, where a message is signed with a private key and verified with the corresponding public key.
        这对于像数字签名这样的功能至关重要，因为消息是用私钥签名的，并用对应的公钥进行验证。

---

**2. (2.5pt) Clogging (resource-depletion) Denial of Service (DoS) attacks cannot be mitigated by stateless firewalls.**
**2. (2.5分) 阻塞（资源耗尽）拒绝服务 (DoS) 攻击无法通过无状态防火墙缓解。**

*   **Answer:**
    **解答：**
    *   **Right.** Stateless firewalls inspect packets in isolation and may not maintain state information that can be used to mitigate some DoS attacks.
        **正确。** 无状态防火墙孤立地检查数据包，并且可能不维护那些可用于缓解某些 DoS 攻击的状态信息。
    *   Other strategies such as rate limiting or IP blacklisting can still provide some level of mitigation against DoS attacks.
        其他的策略（如速率限制或 IP 黑名单）仍然可以提供一定程度的 DoS 攻击缓解。

---

**3. (2.5pt) IPsec Authentication Header (AH) in tunnel mode hides the source and destination host addresses.**
**3. (2.5分) 隧道模式下的 IPsec 认证头 (AH) 会隐藏源主机和目的主机的地址。**

*   **Answer:**
    **解答：**
    *   **Wrong.** IPsec AH provides data origin authentication, data integrity, and replay protection.
        **错误。** IPsec AH 提供数据源认证、数据完整性和重放保护。
    *   However, it does not encrypt the IP packet, which means that while the packet contents are authenticated, they are not hidden; the source and destination IP addresses in the outer IP header remain visible even in tunnel mode.
        然而，它不对 IP 数据包进行加密，这意味着虽然数据包内容经过了认证，但并未被隐藏；即便在隧道模式下，外部 IP 头中的源和目的 IP 地址依然是可见的。

---

**4. (2.5pt) Adding pepper makes password cracking impossible.**
**4. (2.5分) 添加“胡椒粉 (pepper)”使密码破解变得不可能。**

*   **Answer:**
    **解答：**
    *   **Wrong.** Adding 'pepper' can make password cracking more difficult because it adds an additional layer that an attacker must overcome, but it does not make it impossible.
        **错误。** 添加“胡椒粉”可以使密码破解变得更加困难，因为它增加了一个攻击者必须克服的额外层级，但这并不会使其变得不可能。

---

**5. (2.5pt) Kerberos cannot support access to services in an organization different than the one that provided a user with credentials.**
**5. (2.5分) Kerberos 不支持访问与向用户提供凭据的组织不同的其他组织中的服务。**

*   **Answer:**
    **解答：**
    *   **Wrong.** Kerberos can support access to services across different organizations through the use of authentication, where two Kerberos trust each other’s authentication process.
        **错误。** Kerberos 可以支持跨不同组织的服务访问，这是通过使用（跨域）认证实现的，即两个 Kerberos 系统相互信任对方的认证过程。

---

**6. (2.5pt) Border Gateway Protocol (BGP) routers in an Autonomous System (AS) that uses Resource Public Key Infrastructure (RPKI) digitally sign the prefix announcement and the AS-PATH.**
**6. (2.5分) 在使用资源公钥基础设施 (RPKI) 的自治系统 (AS) 中，边界网关协议 (BGP) 路由器会对前缀公告和 AS-PATH 进行数字签名。**

*   **Answer:**
    **解答：**
    *   **Wrong.** RPKI does not digitally sign the route announcement. Instead, it only provides a mean for origin authorization.
        **错误。** RPKI 不会对路由公告进行数字签名。相反，它只提供一种源授权的手段。
    *   It does not sign the path, therefore given RPKI, the path can be tampered with.
        它不签署路径，因此即便有了 RPKI，路径仍可能被篡改。

---

**7. (2.5pt) Secure and fault tolerant communication protocols add significant communication and computation overhead.**
**7. (2.5分) 安全且容错的通信协议会增加显著的通信和计算开销。**

*   **Answer:**
    **解答：**
    *   **Wrong.** Secure and fault-tolerant communication protocols do not necessarily add significant communication and computation overhead.
        **错误。** 安全且容错的通信协议并不一定会增加显著的通信和计算开销。
    *   Some protocols are designed to be lightweight and efficient, adding minimal overhead while still providing security and fault tolerance.
        有些协议设计得很轻量且高效，在增加极小开销的同时仍能提供安全性和容错能力。

---

**8. (2.5pt) The Domain Name System Security Extensions (DNSSEC) authenticates records provided by the authoritative name servers.**
**8. (2.5分) 域名系统安全扩展 (DNSSEC) 认证由权威名称服务器提供的记录。**

*   **Answer:**
    **解答：**
    *   **Wrong.** DNSSEC is designed to provide authentication for all DNS records, not just those provided by authoritative name servers.
        **错误。** DNSSEC 旨在为所有 DNS 记录提供认证，而不仅仅是那些由权威名称服务器提供的记录。
    *   It ensures the authenticity and integrity of all DNS responses, regardless of their source within the DNS infrastructure.
        它确保所有 DNS 响应的真实性和完整性，无论其在 DNS 基础设施中的来源如何。

---

**9. (2.5pt) Random key pre-distribution implies that two neighboring sensor nodes need to perform a so-called key discovery.**
**9. (2.5分) 随机密钥预分配意味着两个相邻的传感器节点需要执行所谓的密钥发现。**

*   **Answer:**
    **解答：**
    *   **Right.** Random key pre-distribution indeed requires that two neighboring sensor nodes perform key discovery to find a common key among the subsets they hold.
        **正确。** 随机密钥预分配确实要求两个相邻的传感器节点执行密钥发现，以便在它们持有的密钥子集中找到一个公共密钥。
    *   This is necessary because each node does not initially know which keys its neighbors possess.
        这是必要的，因为每个节点最初并不知道其邻居拥有哪些密钥。

---

**10. (2.5pt) Two distinct pseudonymous certificates, attached to digitally signed messages by the same entity, cannot be linked by an eavesdropper that is given only the two pseudonymous certificates and the corresponding signatures.**
**10. (2.5分) 同一实体对消息进行数字签名时附带并通过其发送的两个不同的假名证书，在仅给出这两个假名证书和相应签名的情况下，窃听者无法将其关联起来。**

*   **Answer:**
    **解答：**
    *   **Right.** An adversary cannot link the two pseudonymous, since the signatures are generated using two different keys.
        **正确。** 对手无法关联这两个假名，因为签名是使用两个不同的密钥生成的。