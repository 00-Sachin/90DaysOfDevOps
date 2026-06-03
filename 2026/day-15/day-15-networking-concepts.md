Task 1: DNS – How Names Become IPs

The google.com Flow:When I type google.com, 
my browser checks its local cache. If it doesn't know the IP, it asks my OS, which asks my internet provider's DNS resolver. 
The resolver queries the Root server, then the .com TLD server, and finally Google's Authoritative server, which returns the exact IP address back to my browser.

Common Record Types:

A: Maps a domain name directly to an IPv4 address.

AAAA: Maps a domain name directly to an IPv6 address.

CNAME: Maps an alias to another domain name (e.g., www.myapp.com points to myapp.com).

MX:Directs emails to the correct mail server for the domain.

NS: Indicates which DNS servers are authoritative for a domain.Hands-on Check:Bash$ dig google.com


...
;; ANSWER SECTION:
google.com.             135     IN      A       142.250.193.206
...


Observation: Found the A record pointing to 142.250.193.206.
The TTL (Time To Live) is 135 seconds, meaning my system will cache this answer for 135 seconds before asking again.

Task 2: IP AddressingWhat is an IPv4 Address?It is a 32-bit numeric address divided into 4 "octets" (blocks of numbers from 0-255) separated by dots. 
It acts as the unique identifier for a device on a network. Example: 192.168.1.10.


Public vs. Private IPs:


Public IP: Globally unique and routable on the open internet (e.g., Google's 8.8.8.8).

Private IP: Used only within internal networks (like AWS VPCs or your home Wi-Fi). They cannot be routed on the open internet. Example: 10.0.0.5.

Private IP Ranges:

10.0.0.0 to 10.255.255.255

172.16.0.0 to 172.31.255.255

192.168.0.0 to 192.168.255.255

Hands-on Check:Bash$ ip addr show

...
    inet 172.31.35.238/20 brd 172.31.47.255 scope global dynamic eth0
...

Observation: 

My main network interface (eth0) has the IP 172.31.35.238, 
which falls directly into the standard Private IP range.


Task 3: 

CIDR & SubnettingWhat does /24 mean in 192.168.1.0/24?It is CIDR (Classless Inter-Domain Routing) notation. 

The /24 means the first 24 bits of the IP address are locked in as the "Network ID". The remaining 8 bits are left open to be assigned to individual host machines.

Why do we subnet?
To break a massive network into smaller, manageable chunks. 
This improves security (putting databases in a different subnet than web servers), limits network noise (smaller broadcast domains), and stops us from wasting IP addresses.
CIDR Table Exercise:CIDR

Subnet MaskTotal IPsUsable Hosts/24255.255.255.0256254/16255.255.0.065,53665,534/28255.255.255.2401614(Note: 
We always subtract 2 to get "Usable Hosts" because the first IP is reserved for the Network ID and the last IP is reserved for the Broadcast address).

Task 4: Ports – The Doors to ServicesWhat are Ports?If an IP address gets you to the correct building (server), a Port gets you to the correct apartment number (the specific application running inside). 

They allow one server to run multiple services simultaneously.

Common Ports Cheatsheet:
22: SSH (Secure remote login)
80: HTTP (Unencrypted web traffic)
443: HTTPS (Encrypted web traffic)
53: DNS (Domain name resolution)
3306: MySQL (Relational Database)
6379: Redis (In-memory cache)27017:

MongoDB (NoSQL Database)Hands-on Check:Bash$ ss -tulpn
...
tcp   LISTEN 0      128      0.0.0.0:22        0.0.0.0:* users:(("sshd",pid=842,fd=3))
tcp   LISTEN 0      511      0.0.0.0:80        0.0.0.0:* users:(("nginx",pid=1234,fd=6))
...
Observation: I can clearly see SSH listening on port 22 and Nginx web server listening on port 80.

Task 5: Putting It Together

Scenario1: You run curl http://myapp.com:8080First,

DNS translates myapp.com to a specific IP address. 
Then, the application (HTTP) creates a request and uses the transport layer (TCP) to knock on the specific door (8080) of that target IP to ask for the web page.

Scenario 2: Your app can't reach a database at 10.0.1.50:3306First, I would ping 10.0.1.50 to check if I have basic network routing to the machine. 
If that works, I would use nc -zv 10.0.1.50 3306 to check if the specific port is open; if it fails, it's likely an AWS Security Group/Firewall blocking it,
or the database isn't running.What I LearnedCIDR Math makes sense: Realizing that the /number just means "how many bits of the IP address are locked" makes calculating network sizes much less intimidating.

Ports isolate traffic: A single server can host a website, a database, and an SSH session simultaneously without conflict purely because of ports.

Troubleshooting is layered: When a connection fails, you have to check DNS (is the name right?), then the IP (can I reach the server?), and finally the Port (is the door open?).
