这是练习 4 部分的中英对照翻译。

---

### **Exercise 4 Secure and fault tolerant queries (练习 4：安全和容错查询)**

**Original Text:**
Exercise 4 Secure and fault tolerant queries (70 points + 40 extra credit)
Consider B and U registered with their respective CA as above. Assume they run a protocol, with B sending periodically queries to U’s network. It suffices that U or one of its peers, U1, U2, ..., UK respond to B’s query.

**中文翻译：**
**练习 4 安全和容错查询 (70 分 + 40 分额外加分)**
考虑 B 和 U 如上所述在各自的 CA 注册。假设它们运行一个协议，B 定期向 U 的网络发送查询。只要 U 或其对等节点（peers）U1, U2, ..., UK 中的一个响应该查询即可。

---

#### **Question 1**

**Original Text:**
1. (20 pt) Please describe how the queries by B can be authenticated and their integrity and freshness be protected? How can the response by U be safeguarded in the same manner as the query? Reuse concisely steps needed from the previous exercises.

**中文翻译：**
1. (20 分) 请描述 B 的查询如何进行身份验证，并保护其完整性和新鲜度？U 的响应如何以与查询相同的方式受到保护？简要复用之前练习中所需的步骤。

---

#### **Question 2**

**Original Text:**
2. (20 pt) Although one response suffices, by any of the Ui (i= 0,...,K, where U= U0) receiving the query, a naive design would return K+ 1 responses. Assuming all Ui are in the same network, propose a protocol that (i) returns a few if not ideally a single response, and (ii) lets the rest of the Ui know the query was serviced.

**中文翻译：**
2. (20 分) 虽然任何接收到查询的 Ui (i= 0,...,K, 其中 U= U0) 只要有一个响应就足够了，但朴素的设计会返回 K+1 个响应。假设所有 Ui 都在同一个网络中，请提出一个协议，该协议 (i) 返回少量（如果不是理想的一个）响应，并且 (ii) 让其余的 Ui 知道该查询已被服务。

---

#### **Question 3**

**Original Text:**
3. (20 pt) Consider now an adversary, M, in the network of the Ui but not controlling their communication. How can M attempt stopping Ui responses? Can M mislead several (or even all) Ui to respond unnecessarily? Please explain.

**中文翻译：**
3. (20 分) 现在考虑 Ui 网络中有一个对手 M，但他并不控制它们的通信。M 如何试图阻止 Ui 的响应？M 能误导几个（甚至所有）Ui 进行不必要的响应吗？请解释。

---

#### **Question 4**

**Original Text:**
4. (10 pt) How would you change the protocol to have all aforementioned security and functionality and confidentiality for Ui responses?

**中文翻译：**
4. (10 分) 你将如何修改协议，以具备上述所有的安全性、功能性以及 Ui 响应的机密性？

---

#### **Question 5 (Extra Credit)**

**Original Text:**
5. (extra credit 20 pt) Consider now that one of the Ui is adversarial, let’s denote this as Um. Please explain if, given your protocol, Um can provide B with an incomplete answer. If so, please modify your solution (without sacrificing response confidentiality) to either prevent or at least allow the rest of the Ui detect the wrong-doer. You can assume that all Ui have the same data based on which responses are formed. What is the maximum number of wrong-doers your solution can handle?

**中文翻译：**
5. (额外加分 20 分) 现在考虑其中一个 Ui 是恶意的，我们将其记为 Um。请解释在你的协议下，Um 是否能向 B 提供不完整的答案。如果是，请修改你的解决方案（在不牺牲响应机密性的前提下），要么防止，要么至少允许其余的 Ui 检测到作恶者。你可以假设所有 Ui 拥有相同的数据，并基于这些数据生成响应。你的解决方案最多能处理多少个作恶者？

---

#### **Question 6 (Extra Credit)**

**Original Text:**
6. (extra credit 20 pt) Discuss how to change your protocol to efficiently protect the confidentiality of the queries by B to the Ui cluster. If you cannot achieve that, please explain the challenge and the overhead. Can you solve this by changing the network structure on the side of the Ui? Please explain how and briefly point out trade-offs.

**中文翻译：**
6. (额外加分 20 分) 讨论如何更改你的协议，以高效地保护 B 向 Ui 集群发送查询的机密性。如果你无法做到这一点，请解释其中的挑战和开销。你能通过改变 Ui 端的网络结构来解决这个问题吗？请解释如何操作并简要指出其权衡（trade-offs）。

---

### **Answer of exercise 4 (练习 4 的答案)**

#### **Answer 1**

**Original Text:**
1. Queries and responses can be signed with the private keys and verified based on the certificates. The certificates need to be verified based on the answers from the above exercises.
B→U: Query, $t_{\text{clock}}^B$, $\text{Sign}_{\text{PrivB}} (H(t_{\text{clock}}^B, \text{Query}))$, $\text{Cert}_B$
Ui →B: Response, $t_{\text{clock}}^{Ui}$, $\text{Sign}_{\text{PrivUi}} (H(t_{\text{clock}}^{Ui}, \text{Query}, \text{Response}))$, $\text{Cert}_{Ui}$

**中文翻译：**
1. 查询和响应可以使用私钥签名，并根据证书进行验证。证书需要根据上述练习中的答案进行验证。
   B→U: 查询, $t_{\text{clock}}^B$ (B的时间戳), $\text{Sign}_{\text{PrivB}} (H(t_{\text{clock}}^B, \text{Query}))$ (用B私钥对时间戳和查询的哈希进行签名), $\text{Cert}_B$ (B的证书)
   Ui →B: 响应, $t_{\text{clock}}^{Ui}$ (Ui的时间戳), $\text{Sign}_{\text{PrivUi}} (H(t_{\text{clock}}^{Ui}, \text{Query}, \text{Response}))$ (用Ui私钥对时间戳、查询和响应的哈希进行签名), $\text{Cert}_{Ui}$ (Ui的证书)

---

#### **Answer 2**

**Original Text:**
2. When Ui receives a query, it will wait for a short duration before generating the response. The duration is a random value from an acceptable time delay range. The response will be both sent to B and broadcasted within the network of U. If any response to the same query was received before the waiting expire, then no response is generated.

**中文翻译：**
2. 当 Ui 收到查询时，它会在生成响应之前等待一小段时间。这个时长是可接受时间延迟范围内的随机值。响应既会被发送给 B，也会在 U 的网络内广播。如果在等待期满之前收到了对同一查询的任何响应，则不再生成响应。

---

#### **Answer 3**

**Original Text:**
3. M can stop Ui response by immediately sending out a bogus response to a query without waiting, so that all U consider that the query was served. M can mislead multiple or even all U respond if it erase any broadcasted Ui response from U network.

**中文翻译：**
3. M 可以通过不等待并立即发送对查询的伪造响应来阻止 Ui 的响应，这样所有的 U 都会认为该查询已被服务。如果 M 擦除 U 网络中广播的任何 Ui 响应，M 可能会误导多个甚至所有的 U 进行响应。

---

#### **Answer 4**

**Original Text:**
4. The response can be either encrypted with the public key directly or with a symmetric key that is encrypted with the public key.
m←Ui : $E_{K_{Ui B}} \{\text{Response}\}, t_{\text{clock}}^{Ui}, E_{\text{PubB}} \{K_{Ui B}\}$
Ui →B: m, $\text{Sign}_{\text{PrivUi}} (H(m))$, $\text{Cert}_{Ui}$

**中文翻译：**
4. 响应可以直接用公钥加密，也可以用经公钥加密的对称密钥来加密。
   m←Ui : $E_{K_{Ui B}} \{\text{Response}\}$ (用对称密钥加密响应), $t_{\text{clock}}^{Ui}$, $E_{\text{PubB}} \{K_{Ui B}\}$ (用B公钥加密对称密钥)
   Ui →B: m, $\text{Sign}_{\text{PrivUi}} (H(m))$ (对消息m签名), $\text{Cert}_{Ui}$

---

#### **Answer 5**

**Original Text:**
5. Yes, the adversarial Ui can provide dishonest answers by immediately responding without random waiting.
All Ui should share a symmetric key, KU, with the U network.
Ui →B: $E_{K_{Ui B}} \{\text{Response}\}, t_{\text{clock}}^{Ui}, E_{\text{PubB}} \{K_{Ui B}\}, E_{KU} \{K_{Ui B}\}, \text{Sign}_{\text{PrivUi}} (H(\text{Response}, t_{\text{clock}}^{Ui}, K_{Ui B})), \text{Cert}_{Ui}$
Any Ui can see the response, and an honest Ui can respond with an honest response if a dishonest response is received.
B can report conflicting responses if there is any authority is able to figure out which one is dishonest. Otherwise, B has to accept a response with the majority of votes. Any honest Ui should respond until the number of honest responses is greater than the (identical) dishonest response.
Depending on what is the percentage threshold of majority votes, the solution can handle at most K− ⌈precentage∗K⌉ wrong-doers.

**中文翻译：**
5. 是的，恶意的 Ui 可以通过不进行随机等待并立即响应来提供不诚实的答案。
   所有的 Ui 应该在 U 网络内共享一个对称密钥 KU。
   Ui →B: $E_{K_{Ui B}} \{\text{Response}\}, t_{\text{clock}}^{Ui}, E_{\text{PubB}} \{K_{Ui B}\}, E_{KU} \{K_{Ui B}\}$ (用网络共享密钥加密会话密钥), $\text{Sign}_{\text{PrivUi}} (H(\text{Response}, t_{\text{clock}}^{Ui}, K_{Ui B})), \text{Cert}_{Ui}$
   任何 Ui 都能看到响应，如果收到了不诚实的响应，诚实的 Ui 可以发送诚实的响应。
   如果存在能够分辨哪个不诚实的权威机构，B 可以报告冲突的响应。否则，B 必须接受多数票的响应。任何诚实的 Ui 都应该进行响应，直到诚实响应的数量大于（相同的）不诚实响应。
   根据多数票的百分比阈值，该方案最多能处理 $K - \lceil \text{percentage} * K \rceil$ 个作恶者。

---

#### **Answer 6**

**Original Text:**
6. B should send a signed hello message attached with its certificate. Any Ui respond with a signed hello-response based on random waiting mechanism attached with Ui certificate. B can encrypt the query with a symmetric key encrypted with Ui public key. Then Ui responds with encrypted response.
Impossible to solve without introducing extra messages if no key is shared in advance. B can preload the certificate of UGW , a gateway of U network. Then the query can be encrypted with the public key of UGW , and UGW can decrypt and encrypt with a shared symmetric key within the U network before broadcasting to all Ui. Ui respond with the random waiting mechanism, a response encrypted based on the answer for question 4.

**中文翻译：**
6. B 应该发送附带其证书的签名 hello 消息。任何 Ui 基于随机等待机制，响应附带 Ui 证书的签名 hello-response。B 可以用经 Ui 公钥加密的对称密钥来加密查询。然后 Ui 响应加密后的回复。
   如果在预先没有共享密钥的情况下，不引入额外消息是无法解决这个问题的（即无法高效保护查询机密性）。B 可以预加载 UGW（U 网络的一个网关）的证书。然后查询可以用 UGW 的公钥加密，UGW 解密后，使用 U 网络内的共享对称密钥重新加密，并在广播给所有 Ui 之前进行分发。Ui 使用随机等待机制进行响应，响应的加密方式基于问题 4 的答案。