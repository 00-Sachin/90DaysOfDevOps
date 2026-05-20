Day 03 – Linux Commands Practice

Today’s goal is to build a Linux command confidence.

I created a cheat sheet of commands focused on:


Process management

pwd: Prints the current working directory (where are we right now).
ls -la: Lists all files (including hidden ones) with detailed ownership and permission info.
cd /path/to/dir — Changes your directory to the specified path.
mkdir: Creates a new directory.
rm -rf /folder: Forcefully and recursively removes a folder and its contents (use with extreme caution).
cp source.txt dest.txt: Copies a file or directory to a new location.
mv oldname.txt newname.txt — Moves a file, or renames it if the destination is in the same folder.
cat file.txt: Prints the entire contents of a file directly to your terminal.
tail -f /var/log/syslog — Continuously shows the end of a log file as new lines are added.
grep "error" file.txt — Searches inside a file and outputs only the lines containing the specific word.
chmod +x script.sh — Changes the permissions of a file to make it executable.
chown user:group file.txt — Changes the owner and group assigned to a file or directory.


File system

ps aux: Captures a snapshot of every single process currently running on the system.
top: Opens a live, interactive dashboard showing CPU, memory usage, and active processes.
kill -9 <PID> — Forcefully terminates a stuck or rogue process using its Process ID.
df -h — Shows available disk space on your hard drives in a human-readable format (MB/GB).
systemctl status docker — Checks if a background service (like Docker or Nginx) is running or failed.
systemctl restart docker — Stops and immediately starts a service to apply new configurations.
journalctl -u docker — Retrieves the specific background logs for a systemd service to diagnose crashes.


Networking troubleshooting

ping google.com — Tests network connectivity by providing a continuous response.
ip addr — Displays the IP addresses currently assigned to your machine's network interfaces.
curl -I https://google.com : Fetches the HTTP headers of a website to test if the web server is responding.
dig domain.com — Queries the DNS records to see exactly which IP address a domain name points to.
netstat -tulpn — Lists all open network ports on your machine and shows which processes are using them.
