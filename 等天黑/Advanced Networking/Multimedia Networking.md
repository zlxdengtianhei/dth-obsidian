# activities 
Streaming stored audio and video
Streaming live audio and video
Real-time interactive audio and video

# Requirements
Sensitive to end to end delay
sensitive to delay variation(delay jitter)
Less sensitive to occasional loss of data

# Streaming stored audio video
## stored media: 
Pause, rewind, fast-forward, index through content
streaming: 
client begins playout a few seconds after it begins receiving the file
playing out one part while receiving later parts
continuous playout
delays can be tolerated

interactive operations(pause, rwnd, play) must be quick though
TCP/UDP can be used
TCP most common
* Firewalls often block UDP
* Reliable delivery->entire file transferred->allows for caching

Multimedia from Web Server
![[Pasted image 20241014003630.png]]
![[Pasted image 20241014003709.png]]


## Streaming Live Audio/Video
can't fast forward
many simlutaneous receivers
distribution through IP multicast
distribution through application-layer multicast
constrains(限制) less stringent(严格 严厉的) than real-time interactive applications
delays up to tens of seconds may be ok

Send over UDP at a constant rate equal to the drain rate at the receiver
Server clocks out data and client lays out as soon as data is decompressed
delayed playback

## Real-time Interactive Audio/Video
more stringent requirements on delay and delay variations
Delay should not be more than a few hundred milliseconds
Voice
 * delay below 150ms not perceived
 * 150-400 can be acceptable
 * >400ms is frustrating

# In today
Integrated(综合的) services with bandwidth guarantees
Differentiated services with service classes

# RTSP Real-Time Streaming Protocol
For exchanging playback control information
* Pausing, repositioning, fast-forward, rewinding
port 554
Media stream is sent "in-band", not defined by RTSP
can use either UDP and TCP

# Real-Time Traffic
interactive multimedia applications
continuous and delay-sensitive
* delay jitter 

## play buffers
absorbs jitter
predetermined threshold
maximum jitter allowed
packets coming later are dropped
all packets are delayed by this amount at the receiver

# RTP: Real Time Protocol
designed to carry out variety of real time data
sequence number for receiver to detect out-of-order delivery
Timestamp allowing receiver to control playback
Typically UDP
Just provides the mechanisms to build a real-time service
![[Pasted image 20241014010103.png]]

# Recovering from Packet Loss
FEC 
Redundant chunk after every n chucks
XOR-ing the n original chunks
one packet is missing, can fully reconstruct

Interleaving
Sender sends \[1, 5, 9, 13] \[2, 6, 10, 14] \[3, 7, 11, 12]
one lost packet->multiple small disturbances instead of one large gap

# CDN Content Distribution Networks
geographically distributed users
popular content->high bandwidth 

CDN for bringing content closer to the clients

Content provider pushed its content to a CDN code
replicates and pushes to selected CDN servers

url of video are prefixed with http://www.cdn.com

request base HTML
receives reference to www.cdn.com
does DNS lookup to return IP address to best CDN server

CDN server for that access ISP
best CDN base on: 
internet routing tables
round-trip time estimates


