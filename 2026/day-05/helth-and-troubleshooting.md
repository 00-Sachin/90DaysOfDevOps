Mini Runbook: Nginx Health & Troubleshooting
Target Service: nginx
Objective: Capture a system health snapshot, verify filesystem sanity, and trace service logs.

1. Environment Basics
Command: uname -a and cat /etc/os-release

Observation: Successfully identified the operating system version and kernel details before starting work.

2. Filesystem Sanity
Command: mkdir /tmp/runbook-demo && cp /etc/hosts /tmp/runbook-demo/hosts-replica && ls -l /tmp/runbook-demo

Observation: Verified that basic read/write permissions are working perfectly in the /tmp directory.

3. CPU & Memory Health
Command: pgrep nginx (to get the PID) followed by ps -o pcpu,pmem,comm -p <PID>

Observation: Nginx is running and consuming minimal CPU and memory resources.

Command: free -h

Observation: System RAM has plenty of available overhead.

4. Disk & I/O
Command: df -h and du -sh /var/log

Observation: Disk partitions have sufficient free space, and the /var/log directory is not taking up abnormal amounts of storage.

5. Network Connections
Command: ss -tulpn | grep nginx

Observation: Confirmed Nginx is actively listening on its assigned ports (usually 80 and/443) and there are no dead connections (curl -I).

6. Log Tracing
Command: journalctl -u nginx -n 50 and tail -n 50 /var/log/kern.log

Observation: Scanned the last 50 lines of both the Nginx specific logs and the general kernel logs. No critical errors or warnings detected.

🚨 If This Worsens (Escalation Steps)
If Nginx becomes unresponsive or spikes in resource usage, I will take these 3 steps:

Test Configuration & Restart: Run nginx -t to ensure no syntax errors exist, then run sudo systemctl restart nginx to clear the stalled process.

Increase Log Verbosity: Modify the Nginx configuration to enable "debug" level logging to catch exactly where requests are failing.

Trace System Calls: Use strace -p <PID> on the Nginx worker process to see if it is getting stuck trying to read a specific file or connect to a backend database.
