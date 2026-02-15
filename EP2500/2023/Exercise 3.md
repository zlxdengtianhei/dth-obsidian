这是练习 3 部分的中英对照翻译，保持了与之前相同的格式。

---

### **Exercise 3 Certificate revocation (练习 3：证书撤销)**

**Original Text:**
Exercise 3 Certificate revocation (70 points + 20 extra credit)

**中文翻译：**
**练习 3 证书撤销 (70 分 + 20 分额外加分)**

---

#### **Question 1**

**Original Text:**
1. (20 pt) Consider CA-3 informed that A’s private key is compromised. How can W registered with CA-3 be informed that A can no longer be trusted (prior to establishing a secure communication channel with A)? Please explain briefly two solutions.

**中文翻译：**
1. (20 分) 考虑 CA-3 获知 A 的私钥已泄露。如何在 W（注册于 CA-3）与 A 建立安全通信通道之前，通知 W 不能再信任 A？请简要解释两种解决方案。

---

#### **Question 2**

**Original Text:**
2. (20 pt) How can X registered with CA-4 also be informed that A can no longer be trusted? How can X validate a Certificate Revocation List (CRL) by CA-3?

**中文翻译：**
2. (20 分) 注册于 CA-4 的 X 如何也能获知不能再信任 A？X 如何验证由 CA-3 发布的证书撤销列表 (CRL)？

---

#### **Question 3**

**Original Text:**
3. (10 pt) How can U do the same?

**中文翻译：**
3. (10 分) U 如何做到这一点？

---

#### **Question 4**

**Original Text:**
4. (20 pt) What if there are many incidents of users registered with CA-3 that are also compromised? How is each solution handling this?

**中文翻译：**
4. (20 分) 如果 CA-3 注册用户中发生了许多此类泄露事件怎么办？每种解决方案如何处理这种情况？

---

#### **Question 5 (Extra Credit)**

**Original Text:**
5. (extra credit 20 pt) Consider the two solutions for revoking any user certificate, e.g., A’s, and compare their efficiency in terms validating any certificate. What about their effectiveness in terms of timely provision of revocation status?

**中文翻译：**
5. (额外加分 20 分) 考虑撤销任何用户证书（例如 A 的证书）的这两种解决方案，并比较它们在验证任意证书时的效率。它们在及时提供撤销状态方面的有效性又如何？

---

### **Answer of exercise 3 (练习 3 的答案)**

#### **Answer 1**

**Original Text:**
1. Method 1: With a CRL list, which is publicly available, W can check if any certificate issued by CA-3 is revoked.
Method 2: OSCP stapling! The sender attaches a status report for the certificate.

**中文翻译：**
1. 方法 1：通过公开发布的 CRL（证书撤销列表），W 可以检查 CA-3 颁发的证书中是否有被撤销的。
   方法 2：OSCP 装订 (OSCP stapling)！发送方会附上证书的状态报告。
   *(注：原文写作 OSCP，标准全称为 OCSP - Online Certificate Status Protocol)*

---

#### **Answer 2**

**Original Text:**
2. The CRL is publicly distributed and signed by CA-3. X in CA-4 can cross check the signature on the CRL leveraging REG-CA-2, which signs both CA-3 and CA-4.

**中文翻译：**
2. CRL 是公开发布的，并由 CA-3 签名。CA-4 中的 X 可以利用 REG-CA-2 来交叉检查 CRL 上的签名，因为 REG-CA-2 同时签署了 CA-3 和 CA-4（即它们有共同的上级 CA）。

---

#### **Answer 3**

**Original Text:**
3. U cannot do the same, as there is no cross validation between ROOT_CA_1 and ROOT_CA_2

**中文翻译：**
3. U 无法做到这一点，因为 ROOT_CA_1 和 ROOT_CA_2 之间没有交叉验证。

---

#### **Answer 4**

**Original Text:**
4. For method 1 the CRL will contain the revoked certificates at the time of its issuance.
For method 2, when the communication happems, the sender will attach the status report of his certificate.

**中文翻译：**
4. 对于方法 1，CRL 将包含在其发布时已被撤销的证书。
   对于方法 2，当通信发生时，发送方将附上其证书的状态报告。

---

#### **Answer 5**

**Original Text:**
5. Method 1: The CRL is efficient as it pushes the burden of checking which keys are valid and which are not on the client but it is not necessarily timely. Usually CRLs are distributed at a certain frequency and the method relies on the nodes actually checking the CRL.
Method 2: OSCP stapling is efficient and low overhead (and shifts the burden to the sender), but it is not yet supported everywhere.

**中文翻译：**
5. 方法 1：CRL 效率较高，因为它将检查哪些密钥有效、哪些无效的负担推给了客户端，但它不一定及时。通常 CRL 是按一定频率分发的，且该方法依赖于节点实际去检查 CRL。
   方法 2：OSCP 装订效率高且开销低（并将负担转移给发送方），但目前尚未在所有地方得到支持。