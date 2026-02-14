# IPV6
for more address
128 bit address -> IPV4 32

use extension headers instead of options
remove header checksum
remove hop-by-hop fragmentation
only by sender due to path MTU discovery

## header 
Class     new field revised(校正) concept of priority
Flow label     new field to distinguish packet requiring the same treatment
Next header replaces protocol field in IPV4. Extension headers can be used

## addresses
### unicast address
identifies an interface connected to a IP subnet
IPV6 routinely allows each interface to be identified by several addresses
unicast: identifies exactly one interface
multicast: a group; packets get delivered to all members of the group
anycast: identifies a group, normally get delivered to the nearest member of the group
![[Pasted image 20241014231851.png]]

ARP, IGMP are now part of ICMPv6
ICMPv6->error reporting, query

## transition from IPv4 to IPv6
dual stack
tunneling
header translation

# IP QoS

## traditional IP Networking
connectionless best effort service
each packet treated independently by routers
Route lookup base on dst IP address and longest prefix match
no bandwidth guarantees

## advanced
identifying packet flows in the network - classification
give special treatment to each flow - higher degree of service the BE
after classificaiton packet is placed in a certain queue for an outgoing interface
-more specific than the traditional route lookup

## Defining a flow
classification
routers along the path examines both IP and transport level headers

## Function in IP QoS
classification
policing
sharping
scheduling
admission control
## integrated services
Reservation of resources 
RSVP:
used to signal the reservation for each flow
Three service classes for applications to choose from
Guaranteed Service
Controlled Load
Best effort

## Token bucket
a standard way to represent the bandwidth characteristics of an application that generates data at variable rate
any time interval T, sends no more than rT+b bytes


## Resource Reservation Protocol
RSVP is a network control protocol used to express QoS requirements
RSVP binds(绑定) a QoS request to a flow
not carry application data
an important component in IETF int-serv
can be used on traffic engineering/vpn
delivers QoS reservations along a path from source to destination
no routing - routing protocol computes path
uses soft state - periodical refresh

must carry following information:
classification information
traffic specification
QoS requirements
from hosts to all routers along the path

explicitly designed to support multicast

two types of message
Path
from a sender to one or several receivers, carrying TSpec and classification information provided by sender

RESV message
from receiver, carrying RSpec indicating QoS required by receiver

Token bucket specification used in those messages

## RSVP Model
A reservation is unidirectional
PATH and RESV are intercepted(拦截) and forwarded by each router along the path
Each router must take actions to do the actual resource allocation 
Once the reservation established, the routers along the path recognize packets by inspecting IP and transport

reserved flow 
different receivers of the packet flow can have different QoS requirements

### soft state
automatically expire after some time unless it is refreshed
routing protocol determines path dynamically
created and refreshed by PATH and RESV

## Differentiated Services
Divide traffic into small number of classes, and allocate resources per class
use aggregates - no per flow state
service level agreements - no signaling
IP header ToS field - to mark traffic class
flows are aggregated in the network 
router only distinguish between a small number of aggregated flows

## Per Hop Behavior
Forwarding behavior: scheduling, sharping, etc

default
expedited(加速的) forwarding
Assured forwarding

![[Pasted image 20241016230153.png]]






