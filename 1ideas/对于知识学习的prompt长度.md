## Introduction: Wireless networks and security (slides  
1–11)  
This module starts with security of IEEE 802.11 (Wi-Fi), a key Wireless LAN  
(WLAN) technology that also catalyzed nomadic and mobile computing. At  
the second part, we will discuss Wireless Personal Area Networks (WPANs)  
security, Wireless Sensor Network (WSN) security and briefly security and  
privacy for Vehicular Communications (VC) systems. This links this module to  
the next and last one. Wi-Fi is relevant to a broader gamut of systems, offering  
increasing bit rates over the years. While lower-power radios and shorter  
range communication are relevant to small-footprint devices, with resource  
constraints, notably in the Internet of Things (IoT) realm (even though there  
are IoT devices such as connected vehicles that much better provisioned). We  
have already seen in past modules in the course wireless networking, notably  
Mobile Ad-Hoc Networks (MANETs).  
A brief reminder on Wi-Fi: the default and most popular is the infrastructure  
mode, with the Access Point (AP) mediating and regulating communication,  
and security associations between devices and the AP. The ad hoc mode allows  
for device-to–device communication and it has been the catalyst for MANETs.  
Each Wi-Fi frame has a preamble that delimits the start of the frame (a repeated  
symbol string, fixed, whose even partial reception suffices), followed by in-  
formation on the bit rate, packet size, and the medium access control (note:  
to not confuse with Message Authentication Code (MAC)) addresses (of the  
sender, the receiver, including to possibility to multicast or broadcast). Finally,  
error control coding, cyclic redundancy codes that allow transmission error  
detection.  
We focus next on infrastructure mode with AP to mobile node or Mobile Host  
(MH) associations: the basic requirements for security for the AP–MH link are  
confidentiality, authentication and integrity. The approach has been is to use  
symmetric key cryptography. Even though the broader picture that involves user  
authentication and Internet access includes public key cryptography too.  
The typical setup has been that of a manual entry of shared secret on both  
the AP and MH, with a characteristic example of a coffee shop Wi-Fi password  
written on a board. Based on a shared secret, essentially, different protocols  
can be enabled. Nonetheless, having a single key for all MHs connected to  
one AP does not provide flexibility and does not essentially differentiate MHs  
and, in the end, provides limited security. It is important to have flexible  
ways to differentiate users, and control access to the wireless network and the  
Internet accordingly. This can be done by leveraging an authentication server  
2  
(AS) (note: to not be confused with Autonomous System (AS)) or a Public Key  
Infrastructure (PKI) and user certificates.  
Wi-Fi security has evolved over the years, along with the standards and based  
on initiatives and efforts by the industry. It has been an “arms race”, with  
vulnerabilities of proposals identified at each stage. The significant popularity  
of the technology lead to partial or intermediate solutions, also to cater to  
the needs of the deployed base, towards the complete standard proposal.  
Gradually, more security features are added, eradicating vulnerabilities while  
new types of attacks are brought forth.

为我给出与上文中相关的知识，请你从原文中提到的所有内容出发，不要遗漏内容，如有任何的省略请你说明，思考对于哪些是重点，对他们给出详细，易懂，全面的相关知识介绍，在其中可以对重点给出更加详细的介绍，请你尽可能的给出细致，篇幅较长的回答