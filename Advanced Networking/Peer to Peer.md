### client-server architecture
server farms

## P2P
**how to find peers?**
pure vs hybrid P2P systems

# File distribution
$D_{c-s}>=max\{\frac{NF}{u_s}, \frac{F}{d_{min}}\}$

$D_{p2p}>=max\{\frac{F}{u_s}, \frac{F}{d_{min}}, \frac{NF}{u_s+∑u_i}\}$
![[Pasted image 20241017233151.png]]

# Centralized Directory
![[Pasted image 20241017233248.png]]

if server crashes, the entire P2P application crashes

**file transfer is decentralized, but locating is highly centralized

## Query Flooding
![[Pasted image 20241017233642.png]]

dumping a significant amount of traffic
counter decremented every time the query reaches a new peer
only "see" local content

## Hierarchical Overlay Design
group leaders
![[Pasted image 20241017234141.png]]
![[Pasted image 20241017234225.png]]

# DHT(Distributed Hash Table)
看笔记
