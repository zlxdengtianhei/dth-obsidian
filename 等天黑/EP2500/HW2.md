
# Exercise 1
### 1. Bob received the first packet of the flow containing

- H = c4a4d52f
- $b_k$ = 50d02858
- $f_k$ = (1254d56e, f3175f97, 792d0496, 27ecfd3a)

**Will Bob forward the packet $b_k$? Justify the answer.**

**Answer:**  
**No**, Bob will not forward the packet.

**Justification:**  
In the CASTOR protocol, to verify a packet, the node must reconstruct the Merkle tree path from the leaf ($b_k$) to the root ($H$).

- **Subscripts Explanation**: The subscript $k$ in $b_k$ and $f_k$ refers to the specific packet index within the flow. $b_k$ is the identifier for the $k$-th packet, and $f_k$ is the set of sibling hashes needed to verify that specific packet.
- **Iteration Count**: The list $f_k$ contains 4 elements ($x_1, x_2, x_3, x_4$). This means the Merkle tree has a depth that requires 4 hashing steps to reach the root. Therefore, we must perform 4 iterations of combining the current hash with the next element in $f_k$.

**Calculation Steps:**  
Bob computes the hash chain using the 8-char truncated MD5:

1. **Initial Hash**: Compute hash of the packet identifier.  
    $h(b_k) = h(50d02858) = 07f4e832$
    
2. **Iteration 1**: Combine with first element of $f_k$ (1254d56e).  
    $h(07f4e832 || 1254d56e) = 60517724$
    
3. **Iteration 2**: Combine with second element of $f_k$ (f3175f97).  
    $h(60517724 || f3175f97) = 7762692e$
    
4. **Iteration 3**: Combine with third element of $f_k$ (792d0496).  
    $h(7762692e || 792d0496) = 2c8374d7$
    
5. **Iteration 4**: Combine with fourth element of $f_k$ (27ecfd3a).  
    $h(2c8374d7 || 27ecfd3a) = 491330b1$
    

**Conclusion**:  
The final computed hash is **491330b1**.  
The expected flow identifier $H$ is **c4a4d52f**.  
Since $491330b1 \neq c4a4d52f$, the verification fails, and Bob will drop the packet.

---

### 2. Alice instead received the first packet of a new flow containing

- H = 12328e72
- $b_k$ = 07fd01d5
- $f_k$ = (5f989003, aade1a0e, f2017bf1, 43743eeb)

**Will Alice forward the packet $b_k$? Justify the answer.**

**Answer:**  
**No**, Alice will not forward the packet.

**Justification:**  
Similar to Bob's case, Alice must verify the packet by hashing $b_k$ with the elements in $f_k$.

- The list $f_k$ has 4 elements, so there are 4 iterations after the initial hash.

**Calculation Steps:**

1. **Initial Hash**: Compute hash of the packet identifier.  
    $h(b_k) = h(07fd01d5) = 6f3a763d$
    
2. **Iteration 1**: Combine with first element of $f_k$ (5f989003).  
    $h(6f3a763d || 5f989003) = 602d4be0$
    
3. **Iteration 2**: Combine with second element of $f_k$ (aade1a0e).  
    $h(602d4be0 || aade1a0e) = 3b28f70d$
    
4. **Iteration 3**: Combine with third element of $f_k$ (f2017bf1).  
    $h(3b28f70d || f2017bf1) = 74134988$
    
5. **Iteration 4**: Combine with fourth element of $f_k$ (43743eeb).  
    $h(74134988 || 43743eeb) = ea55fb26$
    

**Conclusion**:  
The final computed hash is **ea55fb26**.  
The expected flow identifier $H$ is **12328e72**.  
Since $ea55fb26 \neq 12328e72$, the verification fails, and Alice will drop the packet.

# Exercise 2

**1. (10 pt.) Consider a case where the integrity checks (in steps 3 and 4, H(K||all_prev_messages)) include only nonces (RA and RB). Is the protocol secure after this modification? If not, come up with an attack scenario; otherwise please explain why.**

**Answer:**  
No, the protocol is **not secure** with this modification. It becomes vulnerable to a **Downgrade Attack**.

**Attack Scenario:**  
An active adversary (Mallory) intercepts the message in Step 1. She modifies the `crypto offered` list, removing strong algorithms (e.g., AES) and leaving only a weak one (e.g., "NULL" encryption or export-grade cipher). Bob receives the modified list, selects the weak algorithm (`crypto selected`), and sends it back. Since the integrity checks in Steps 3 and 4 only calculate $H(K || R_A || R_B)$ and ignore `crypto offered` and `crypto selected`, Alice and Bob will successfully verify the hash, unaware that they have been tricked into using a weak cipher, which Mallory can easily break.

---

**2. (5 pt.) What is a downgrade attack in the context of TLS? Explain and give one example attack scenario.**

**Answer:**  
A downgrade attack is a scenario where an active attacker interferes with the protocol's handshake negotiation to force the client and server to use a weaker version of the protocol or a weaker cryptographic algorithm than they both actually support.

**Example Scenario:**  
A client supports both TLS 1.2 (secure) and SSL 3.0 (insecure). An attacker intercepts the `ClientHello` message and modifies it to look like the client _only_ supports SSL 3.0. The server, seeing only SSL 3.0, agrees to use it. The session is established using the vulnerable SSL 3.0 protocol, allowing the attacker to exploit known vulnerabilities (like POODLE) to decrypt the traffic.

---

**3. (15 pt.) What is perfect forward secrecy (PFS)? Does this instance of the protocol in Figure 1 have perfect forward secrecy? If yes, please explain how it achieves this property. If your answer is no, then please explain why it fails and revise the protocol.**

**Answer:**  
**Perfect Forward Secrecy (PFS)** is a property ensuring that the compromise of long-term keys (like a server's private key) does not compromise past session keys. If the private key is stolen in the future, previously recorded encrypted traffic cannot be decrypted.

**Does Figure 1 have PFS?**  
**No.** In Figure 1, Alice encrypts the pre-master secret $S$ using Bob's public key ($C \leftarrow Enc_{Pub_B}(S)$). If an adversary records the traffic today and steals $Priv_B$ next year, she can compute $S \leftarrow Dec_{Priv_B}(C)$, derive $K$, and decrypt the entire recorded session.

**Revised Protocol (using Ephemeral Diffie-Hellman):**  
To achieve PFS, we replace RSA encryption of $S$ with a Diffie-Hellman exchange signed by the long-term key.

**Notation Assumptions:**

- $g, p$: Public DH parameters agreed upon in hello messages.
- $x, y$: Ephemeral private secrets generated by Alice and Bob respectively ($x, y \leftarrow RNG$).
- $g^x, g^y$: Ephemeral public values.

**Revised Protocol Steps:**

1. $A \rightarrow B$: ClientHello, crypto offered, $R_A$
2. $B$: $y \leftarrow RNG$  
    $B \rightarrow A$: ServerHello, crypto selected, $Cert_B$, $R_B$, $g^y$, $\sigma \leftarrow Sign_{Priv_B}(g^y || R_A || R_B)$
3. $A$: $Success/Failure \leftarrow Ver_{Pub_B}(\sigma)$  
    $A$: $x \leftarrow RNG$  
    $A$: $S \leftarrow (g^y)^x \mod p$  
    $A$: $K \leftarrow f(S, R_A, R_B)$  
    $A \rightarrow B$: $g^x$, $H(K || all_prev_messages)$
4. $B$: $S \leftarrow (g^x)^y \mod p$  
    $B$: $K \leftarrow f(S, R_A, R_B)$  
    $B \rightarrow A$: $H(K || all_prev_messages)$

$S$ is now calculated mathematically ($g^{xy}$) rather than transmitted encrypted. Even if $Priv_B$ is stolen later, the attacker cannot recover $x$ or $y$ (which are deleted after the session) to reconstruct $S$.


# Exercise 3

1. (5 pt.) What is bailiwick checking, and how does it relate to zone delegation?

**Answer:**  
**Bailiwick checking** is a security mechanism used by recursive resolvers to ensure that a DNS server only provides information within its scope of authority (its "bailiwick"). It prevents a server from providing cached data for domains it does not own.  
It relates to **zone delegation** because when a parent zone delegates authority to a child zone's nameserver, that nameserver is only trusted to answer queries for that specific child zone. Bailiwick checking ensures that if the child nameserver tries to send records for a completely different domain (e.g., `example.com`'s server trying to send a record for `google.com`), the resolver ignores them to prevent cache poisoning.

2. (5 pt.) What is the use of the glue records? When is it required and what happens if the glue is missing? Is there any scenario where glue does not need to be included?

**Answer:**  
**Glue records** are A or AAAA records provided by the parent zone that contain the IP address of a child zone's nameserver. They are used to bootstrap the resolution process.

- **When required:** Glue is required when a "circular dependency" exists—specifically, when the nameserver for a zone is a subdomain of that zone itself (e.g., the nameserver for `example.com` is `ns1.example.com`).
- **If missing:** The resolver enters an infinite loop or fails to resolve the domain because it cannot find the IP address of the nameserver needed to answer the query.
- **Scenario where not needed:** Glue is not needed if the nameserver is "out-of-bailiwick" (e.g., `example.com` uses `ns1.registrar-servers.com`), because the resolver can resolve the nameserver's IP independently via the normal DNS hierarchy.

3. (5 pt.) What is the use of the NXDOMAIN response? What type of attack can occur if it is abused?

**Answer:**  
The **NXDOMAIN** (Non-Existent Domain) response is a status code sent by a DNS server to indicate that the queried domain name does not exist.  
If abused, it can lead to an **NXDOMAIN Flood** (or "Water Torture") attack. In this Denial of Service (DoS) attack, the adversary sends a massive number of queries for random, non-existent subdomains (e.g., `xyz123.target.com`). Because these random names are not in the cache, the recursive resolver is forced to forward every query to the authoritative server, exhausting the resources of both the resolver and the authoritative infrastructure.

4. (5 pt.) How is the Time-To-Live (TTL) used in DNS? How can the attacker abuse it (consider both small and big values)?

**Answer:**  
**TTL** indicates how long a DNS record should be stored in a resolver's cache before it must be discarded and refreshed from the authoritative server.

- **Small TTL Abuse:** Attackers use very short TTLs (e.g., 0 or 1 second) to facilitate **DNS Rebinding** attacks (bypassing browser Same-Origin Policy) or to prevent caching, forcing resolvers to spam the authoritative server with queries to cause a Denial of Service.
- **Big TTL Abuse:** Attackers use very long TTLs in **Cache Poisoning** attacks. If an attacker successfully injects a malicious record into a resolver's cache, a long TTL ensures the victim remains redirected to the malicious site for a long period (days or weeks) without the resolver checking for the correct IP.

# Exercise 4

**1. (5 pt.) What is the use of the NSEC resource record when using DNSSEC? How can this record be abused and to what end?**  
**Answer:**  
The NSEC (Next Secure) record is used to provide **Authenticated Denial of Existence**. Since DNSSEC cannot digitally sign a "non-existent" response for every possible missing query, NSEC records create a chain of all valid domain names in a zone sorted alphabetically. When a user queries a non-existent name, the server returns an NSEC record linking the previous valid name to the next valid name, proving the queried name does not exist between them.

**Abuse:** This can be abused for **Zone Walking** (or Zone Enumeration). An attacker can sequentially query non-existent names to retrieve all NSEC records. By chaining these records together, the attacker can reconstruct the entire zone file, revealing the complete list of subdomains (e.g., `secret-admin.example.com`), which aids in reconnaissance for further attacks.

**2. (5 pt.) Provide a simple and complete NSEC resource record trace/example illustrating the problem from above. (Hint: you can use dig/other tools; you can also check rfc4034)**  
**Answer:**  
Assume a zone `example.com` contains only two subdomains: `api.example.com` and `db.example.com`.

**Attack Step:** The attacker queries for a non-existent name, `blog.example.com`.  
`Query: dig +dnssec blog.example.com`

**Response:** The server returns an NSEC record indicating the range where `blog` would have been.  
`api.example.com. 3600 IN NSEC db.example.com. ( A RRSIG NSEC )`

**Explanation:** This record explicitly tells the attacker:

1. `api.example.com` exists.
2. `db.example.com` exists.
3. **Nothing** exists alphabetically between `api` and `db`.  
    By repeating this process (querying something after `db`), the attacker can map the entire network structure.

**3. (10 pt.) How can this problem be solved? Does the solution have any pitfalls and/or constraints (provide at least 2 arguments)?**  
**Answer:**  
The problem is solved using **NSEC3** (Next Secure Record version 3). Instead of listing the next domain name in cleartext, NSEC3 lists the **cryptographic hash** of the next domain name (often salted). This proves a name doesn't exist without directly revealing what _does_ exist.

**Constraints:**

1. **Computational Overhead:** NSEC3 requires the authoritative DNS server to compute hashes for every denial-of-existence response and requires resolvers to verify them. This increases the CPU load on the DNS infrastructure compared to the simpler NSEC.
2. **Vulnerability to Offline Dictionary Attacks:** While the names are hashed, the domain name space is often low-entropy (common words like "mail", "www", "admin"). An attacker can collect the NSEC3 hashes and use high-speed GPUs to perform offline dictionary or brute-force attacks (e.g., using Hashcat) to recover the original domain names.

**4. (15 pt.) If we already have DNSSEC, why do we need DNS over TLS (DoT) or DNS over HTTPS (DoH)? How do they differ from DNSSEC and from one another? Give one example for each (DoT and DoH) that affects system administrators’ actions (think based on on all the course modules) and explain why.**  
**Answer:**  
**Why needed:** DNSSEC provides **integrity** and **authenticity** (ensuring data hasn't been spoofed or modified), but it transmits data in **cleartext**. DoT and DoH are needed to provide **confidentiality** (privacy) by encrypting the transport channel between the client and the resolver, preventing eavesdropping by ISPs or local attackers.

**Differences:**

- **DNSSEC vs. DoT/DoH:** DNSSEC protects the _data_ (via signatures), while DoT/DoH protect the _connection_ (via TLS encryption).
- **DoT vs. DoH:** DoT uses a dedicated port (853) strictly for DNS. DoH encapsulates DNS queries within standard HTTPS traffic on port 443.

**System Administrator Examples:**

- **DoT Example:** A firewall administrator must explicitly **open TCP port 853** to allow DoT traffic. Conversely, if they wish to block encrypted DNS to force users to use the company's monitored DNS, they can easily block port 853, as it is distinct and dedicated to this protocol.
- **DoH Example:** Because DoH traffic looks like standard web traffic (HTTPS on port 443), it is **difficult for administrators to filter or monitor**. An administrator cannot easily block DoH without blocking all HTTPS web browsing or deploying complex "TLS Inspection" (Man-in-the-Middle) proxies. This makes it harder to enforce DNS-based content filtering (e.g., blocking gambling sites) or detect malware command-and-control lookups.
# Exercise 5
**1. Explain how an attacker could conduct a relay/wormhole attack? (10 pt)**  
**Answer:**  
An attacker places two devices to bridge the physical distance between the legitimate Reader ($R$) and the legitimate Card ($C$).

1. **Proxy Card ($Ca$):** Placed near the legitimate Reader ($R$). It emulates a card.
2. **Proxy Reader ($Ra$):** Placed near the legitimate Card ($C$). It emulates a reader.
3. **Relay:** $Ca$ and $Ra$ are connected via a high-speed communication link (e.g., Wi-Fi or RF). When $R$ sends a signal, $Ca$ captures it, transmits it to $Ra$, and $Ra$ replays it to $C$. $C$'s response is sent back through $Ra$ to $Ca$, which replays it to $R$.  
    This tricks $R$ into believing $C$ is within the required proximity (10cm) when it is actually far away.

**2. Use the protocol notation to describe the relay/wormhole attack? (15 pt)**  
**Answer:**  
Let $Ca$ be the attacker's device near the Reader, and $Ra$ be the attacker's device near the Card. The symbol $\leftrightarrow$ represents the attacker's internal high-speed link.

- **Step 3a:** $R \rightarrow Ca$: m1(Probe)
    - _(Relay)_: $Ca \leftrightarrow Ra$
    - $Ra \rightarrow C$: m1(Probe)
- **Step 3b:** $C \rightarrow Ra$: m2(Probe Response)
    - _(Relay)_: $Ra \leftrightarrow Ca$
    - $Ca \rightarrow R$: m2(Probe Response)
- **Step 3c:** $R \rightarrow Ca$: m3(IDC)
    - _(Relay)_: $Ca \leftrightarrow Ra$
    - $Ra \rightarrow C$: m3(IDC)
- **Step 3d:** $C \rightarrow Ra$: m4(IDC, Data Tr. Start)
    - _(Relay)_: $Ra \leftrightarrow Ca$
    - $Ca \rightarrow R$: m4(IDC, Data Tr. Start)
- **Step 3e:** $C \rightarrow Ra$: m5(Data)
    - _(Relay)_: $Ra \leftrightarrow Ca$
    - $Ca \rightarrow R$: m5(Data)

**3. Can the previous attack be thwarted if m2 is digitally signed by the card? \[You can assume the card can perform public key cryptographic operations.] If yes, explain why. If not, can any other crypto solve this problem? (10 pt)**  
**Answer:**  
**No**, the attack cannot be thwarted by digitally signing m2.

**Reason:** A relay attack works at the physical layer by extending the signal range; it does not require the attacker to modify the message content. The attacker simply forwards the valid, signed message $m2$ from $C$ to $R$. $R$ will verify the signature successfully, proving the message originated from $C$, but the signature proves nothing about $C$'s physical location or distance.

**Other Crypto:** Standard cryptographic primitives (encryption, hashing, signatures) cannot solve this problem because they authenticate _data_ and _identity_, not _physical distance_.

**4. Given the protocol description (3a to 3e), how could the attack be thwarted? Again, please list the steps of the augmented protocol. (Hint: Distance between R and C should be typically very short.) (15 pt)**  
**Answer:**  
The attack can be thwarted by implementing a **Distance Bounding Protocol**. This relies on the physical limitation of the speed of light to measure the Round Trip Time (RTT) of a challenge-response exchange.

**Augmented Protocol Steps:**  
A rapid bit-exchange phase (usually done in hardware) before the data transmission.

1. **Setup:** $R$ and $C$ establish a session and agree on a function $f$ using XOR.
2. **Challenge-Response (Distance Measurement):**
    - $R$ generates a random nonce/bit $N$.
    - $R \rightarrow C$: $N$ (Reader starts high-precision timer $T_{start}$)
    - $C$ immediately calculates response $Resp = f(N, Key)$ (e.g., $N \oplus K$) and sends it.
    - $C \rightarrow R$: $Resp$
    - $R$ receives $Resp$ (Reader stops timer $T_{end}$).
3. **Verification:**
    - $R$ checks if $Resp$ is correct.
    - $R$ calculates $\Delta t = T_{end} - T_{start}$.
    - $R$ calculates distance $D = c \times \frac{\Delta t}{2}$ (where $c$ is the speed of light).
4. **Decision:** If $D \le 10cm$ (or $\Delta t$ is below a strict threshold), proceed to Step 3c. Otherwise, abort.

The relay attack introduces processing and transmission delays across the attacker's link, causing $\Delta t$ to exceed the threshold.

# Exercise 6
1. (5 pt.) Motivate why pairing is an operation of fundamental importance for security in IoT. What is the purpose of the pairing key and how is it used to achieve a secure connection between two IoT devices?  
    **Answer:**  
    Pairing is fundamental because IoT devices often communicate over open wireless channels where physical access cannot be restricted. Pairing establishes a root of trust between two devices that have not communicated before.  
    The purpose of the **pairing key** is to serve as a shared secret to authenticate the devices and derive subsequent session keys (like the Long Term Key). It is used to encrypt the connection, ensuring **confidentiality** (preventing eavesdropping) and **integrity** (preventing data tampering) for all future data exchange.
    
2. (10 pt.) Discuss the main security issues of Just Works. How does Just Works handle authentication? What issues arise from using a static temporary key? How are man-in-the-middle attacks handled?  
    **Answer:**  
    **Security Issues:** Just Works is vulnerable because it provides no protection against active attacks.  
    **Authentication:** It does **not** provide authenticated encryption. Since $TempKey$ is fixed to 0, there is no secret material verifying the identity of the other party.  
    **Static Key Issues:** Because the temporary key is always 0 (public knowledge) and the nonces are exchanged in plaintext, any passive eavesdropper can calculate the resulting $PairKey$ and decrypt the entire session.  
    **MitM Attacks:** Just Works cannot handle Man-in-the-Middle (MitM) attacks. An attacker can transparently sit between the Central and Peripheral, negotiating separate keys with each (using 0). Since there is no user verification step, the users have no way of knowing they are not talking directly to each other.
    
3. (10 pt.) Explain how Numeric Comparison improves upon Just Works. Describe the additional steps it introduces, why they strengthen security, and which security guarantees are added compared to Just Works.  
    **Answer:**  
    **Improvements:** Numeric Comparison improves security by using **ECDH** (Elliptic Curve Diffie-Hellman) for key generation and adding a **User Confirmation** step.  
    **Additional Steps:**
    
4. **ECDH Exchange:** Devices exchange public keys ($P_c, P_p$) to derive a shared secret ($DHKey$). This protects against passive eavesdropping because an attacker cannot compute the key just by seeing the public keys.
    
5. **User Confirmation:** Both devices calculate a 6-digit value $V$ based on the $DHKey$ and Nonces, and display it. The user manually confirms they match.  
    **Security Guarantees:** This adds **Authentication** and protection against **MitM attacks**. If an attacker tries to intercept the ECDH exchange, they would have to inject their own public keys, resulting in different $DHKeys$ (and thus different values $V$) on the two devices. The user would see mismatched numbers and reject the connection.
    
6. (20 pt.) In cryptographic protocols, a commitment is a mechanism where an entity pre-determines a value and proves that they are bound to that value, without revealing the value itself. The goal of a commitment is to avoid the entity from changing idea later, ensuring that the entity cannot influence the result anymore after sending the commitment to the other party. Improve the security of the Numeric Comparison protocol by leveraging a commitment. Do this by adding new messages exchanged by the central and the peripheral.  
    **Answer:**  
    In the simplified protocol (Figure 3), the nonces ($N_c, N_p$) are exchanged directly. If an active attacker can intercept $N_c$ before sending their own $N_p$ (or vice versa), they might manipulate their nonce to influence the final value $V$. A commitment scheme prevents this by forcing one party to "lock in" their nonce before the other party reveals theirs.
    

**Revised Protocol with Commitment:**  
We modify the exchange of Nonces (after the Public Key exchange and before the calculation of $V$). The Central commits to $N_c$ first, then the Peripheral sends $N_p$, and finally, the Central reveals $N_c$.

**Step-by-step Exchange:**

1. **Central:** Generates random nonce $N_c$.
2. **Central:** Computes Commitment $C = Hash(N_c)$.
3. **Central $\rightarrow$ Peripheral:** Sends $C$ (Commitment).
    - _Note: At this point, Central is bound to $N_c$, but Peripheral does not know $N_c$._
4. **Peripheral:** Generates random nonce $N_p$.
5. **Peripheral $\rightarrow$ Central:** Sends $N_p$.
    - _Note: Peripheral cannot choose $N_p$ based on $N_c$ because $N_c$ is still hidden._
6. **Central $\rightarrow$ Peripheral:** Sends $N_c$ (Reveal).
7. **Peripheral:** Verifies that $Hash(N_c) == C$. If the check fails, abort.
8. **Both:** Proceed to calculate $V = f(DHKey, N_c, N_p)$ and display it for user confirmation.