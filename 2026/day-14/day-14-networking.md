The OSI Model


The OSI (Open Systems Interconnection) model is a theoretical framework that describes how data moves from a local device across a network to a server,
and vice versa. It standardizes network functions into 7 distinct layers, moving from the hardware level up to the user software.

Layer 1: Physical Layer

What it does: Handles the physical connection between devices and transmits raw bitstreams (0s and 1s) over electrical, radio, or optical signals.

Examples: Ethernet (LAN) cables, Wi-Fi radio waves, hubs, and repeaters.

Layer 2: Data Link Layer

What it does: Packs raw bits into frames and ensures error-free data transfer between two directly connected nodes. It uses MAC addresses (physical addresses) to identify specific devices on the same local network.

Examples: Switches, Network Interface Cards (NICs).

Layer 3: Network Layer

What it does: Responsible for routing data between different networks. It translates MAC addresses into logical IP addresses and breaks data down into packets to find the best path across the internet.

Examples: Routers, IPv4, IPv6.

Layer 4: Transport Layer

What it does: Manages end-to-end communication, flow control, and error detection. It determines how data is broken into segments and transmitted.

Protocols: TCP (reliable, ensures all data arrives safely) and UDP (fast, used for live streaming/gaming where dropping a few packets is fine).

Layer 5: Session Layer

What it does: Spans, manages, and terminates connections (sessions) between the local device and the remote server. It ensures the connection stays open while data is moving and closes it when done.
It also handles authentication and authorization.

Layer 6: Presentation Layer

What it does: Functions as the data translator. It ensures that data from the application layer is formatted, compressed, and encrypted (or decrypted) so the receiving system can understand it.

Examples: SSL/TLS encryption, JPEG, MP3.

Layer 7: Application Layer

What it does: The layer closest to the end-user. It interacts directly with software applications (like web browsers) to enable network services. It doesn't display the UI itself,
but it provides the protocols that allow applications to request and receive data.

Protocols: HTTP, HTTPS, SSH, FTP, SMTP (email).

The TCP/IP Model
The TCP/IP model is the practical, real-world architecture used by the internet and modern industries today. Instead of 7 layers, it condenses the networking process into 4 layers by combining the functions of several OSI layers.

Layer 1: Network Access Layer (Combines OSI's Physical and Data Link layers)

What it does: Defines how data is physically sent through the network hardware. It handles everything from physical cables and wireless signals to mapping IP addresses to hardware MAC addresses.

Layer 2: Internet Layer (Corresponds to OSI's Network layer)

What it does: Handles logical addressing, routing, and packaging of data into packets. It ensures data reaches its destination network regardless of the path it takes.

Protocols: IP, ICMP (ping).

Layer 3: Transport Layer (Corresponds to OSI's Transport layer)

What it does: Controls host-to-host communication. It decides whether data needs to travel reliably and sequentially (TCP) or rapidly without strict delivery checks (UDP).

Layer 4: Application Layer (Combines OSI's Session, Presentation, and Application layers)

What it does: Handles everything related to user applications, data formatting, encryption, and session management. It allows your browser or software to communicate safely and directly with a web server.

Protocols: HTTPS, HTTP, SSH, DNS.


IN Tcp model 

IP is stack in internt layer 

TCP/UDP is tack in Transport Layer

HTTP/HTTPS, DNS are in Application Layer

2. Hands-on Checklist
Target Host for external checks: google.com

Identity: hostname -I

Observation: Returned 172.31.35.238. This is my AWS EC2 instance's internal private IP address, not the public one attached to the internet gateway.

Reachability: ping -c 4 google.com

Observation: 0% packet loss. Average latency was ~1.5ms, which is incredibly fast (AWS data centers have great routing).

Path: traceroute google.com

Observation: The traffic took about 8 hops to reach Google's servers. The first hop was my local AWS gateway, and a few middle hops returned * * * (timeouts), meaning those specific routers are configured to ignore traceroute requests for security.

Ports: ss -tulpn

Observation: Found sshd (the SSH service) listening on TCP port 22.

Name Resolution: dig google.com +short

Observation: DNS resolved the domain name to 142.250.193.206.

HTTP Check: curl -I https://google.com

Observation: Returned HTTP/2 200, meaning the web server is healthy and successfully accepted the request.

Connections Snapshot: netstat -an | grep ESTABLISHED | wc -l

Observation: Piped to wc -l to count the lines. Found exactly 1 established connection (which is my active SSH session into the server).

3. Mini Task: Port Probe

   
I identified that SSH is listening on port 22 from the ss command.

Test Command: nc -zv localhost 22

Result: Connection to localhost (127.0.0.1) 22 port [tcp/ssh] succeeded!

Reflection: The service is actively accepting connections. If this had failed (e.g., "Connection refused"),
my next step would be checking if the service is actually running (systemctl status sshd) or if a local firewall is blocking it (ufw status).

4. Reflection

   
Fastest Signal: curl -I <url> is the fastest way to check an entire stack. If it returns a 200, I know DNS, IP routing, TCP handshakes, and the web application are all functioning perfectly.

Troubleshooting Layers: * If DNS fails (e.g., ping server.local says "Name or service not known"), the issue is at the Application Layer (L7). I need to check my /etc/resolv.conf or my DNS provider.

If I see an HTTP 500 error, the network is fine. The issue is strictly at the Application Layer (L7)—specifically, the web server code crashed while processing the request. I need to check application logs.

Follow-up incident checks:

Check if the SSL certificate expired using curl -vI https://...

Check if a firewall rule was unexpectedly applied dropping traffic (e.g., checking AWS Security Groups).
