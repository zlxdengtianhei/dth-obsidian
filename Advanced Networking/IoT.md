# Protocols
Application: HTTP CoAP MQTT
Transport: TCP, UDP
Network, routing: IPv6, RPL
Adaptation: 6LoWPAN
MAC: CSMA/CA
Radio Duty Cycling: ContikiMAC, TSCH
Radio: IEEE 802.15.4

# CoAP
Application protocols for constrained devices

Machine-to-machine communication a driving force
very small footprint, RAM, ROM

Resource Discovery
Observe
UDP Port 5683
Reliable unicast
Best effort multicast

Confirmable message
Non-confirmable message
ACK
Reset
Response
## Sensor Network - Application Level
![[Pasted image 20241018202000.png]]

# Publish-Subscribe Model

![[Pasted image 20241018212116.png]]

# MQTT
run over TCP
Devices can publish and subscribe to different "topics"
Once a topic updated, subscribers get notified and get data via the broker![[Pasted image 20241018215439.png]]

# Network level protocols
Stateless Autoconfiguration (SLACC)
servers keep no state about hosts(like global unicast prefix and subnet prefix)
Uses IPv6 concept of link local addresses to enable clients to communicate on local subnet before having a global address
Client does not explicitly request address from server
does not even explicitly inform the server of address selected

## IPv6 addressing
unicast: identifies an interface connected to an IP subnet(as IPv4)
IPv6 allows each interface to be identified by several addresses

## Link Local Address in SLACC
![[Pasted image 20241018223933.png]]
第一个字节第7位取反，两字节一样，接两字节：FFFE，后三字节一样

Once unique LLA is established, this can be used to communicate with other hosts on same subet

Routers on local subnet broadcast periodic Router Advertisements ICMP messages
Hosts can also sent ICMP to solicit(请求)

RA contains the global unicast prefix and subnet prefix
Clients combines LLA with prefixes to create its unique global address

![[Pasted image 20241018225138.png]]

## Routing over Low-power Lossy Networks(LLN)
Radio intended to cover only 5-10m - routing essential

### PRL 
IPv6 Routing Protocol
distance vector
runs in host and routers

encapsulate in ICMPv6

via Object Function separate routing optimization from packet handling

OF gives a "rank" used for tree/parent selection and loop prevention
Rank decreases towards destination