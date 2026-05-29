1. Mindset & Plan Review
   
Looking back at my Day 01 goals, the plan is still rock solid. My primary goal was to devlop a devops ready mindset to crack high paying job.
 

2. Processes & Services Re-run
   
I jumped back into checking system health to keep the muscle memory fresh.

Command: systemctl status ssh

Observation: The SSH service is active and running cleanly.

Command: journalctl -u ssh -n 5

Observation: Checked the last 5 logs for the SSH daemon. No failed login attempts or errors, just standard connection acceptances.

3. File Skills & User/Group Sanity Check
   
Combined file operations and ownership changes into one quick drill.

Bash
# 1. Create a dummy file
touch /tmp/revision-test.txt

# 2. Append some text
echo "Revision day practice" >> /tmp/revision-test.txt

# 3. Change ownership (practicing Day 11 skills)
sudo chown professor:admins /tmp/revision-test.txt

# 4. Lock down permissions to read-only for owner/group, nothing for others
sudo chmod 440 /tmp/revision-test.txt

# 5. Verify the changes
ls -l /tmp/revision-test.txt
Observation: The output  -r--r----- 1 professor admins ... confirmed my numeric chmod math is getting much faster!

4. Cheat Sheet Refresh
If the server is on fire, these are the 5 commands I am reaching for first:

systemctl status <service> (Is it running?)

journalctl -eu <service> (Jump straight to the newest errors)

top or htop (What is eating the CPU/RAM right now?)

df -h (Is the disk completely full?)

history | grep <keyword> (What did I or someone else just type to break this?)

5. Mini Self-Check
Which 3 commands save you the most time right now, and why?

history | grep: Saves me from having to re-type long, complex commands I figured out yesterday.

systemctl is-active: Much faster than reading the full status output when I just need a quick yes/no on service health.

chown -R: The recursive flag saves me from having to manually change ownership on dozens of nested files.

How do you check if a service is healthy? List the exact 2–3 commands you’d run first.

systemctl status <service-name> (Checks if it is active or failed).

journalctl -u <service-name> -n 50 (Checks for recent errors in the logs).

systemctl is-enabled <service-name> (Verifies if it will survive a reboot).

How do you safely change ownership and permissions without breaking access? Give one example command.
I always verify my exact location with pwd before running commands, and I use specific numeric permissions rather than broad strokes.
Example: sudo chmod 755 /opt/myapp (Gives me full control, but safely restricts everyone else to read/execute only).

What will you focus on improving in the next 3 days?
I want to get faster at navigating the terminal without looking up the flags for basic commands like chmod and ls. 
I also want to focus on reading logs more efficiently—spotting the actual error message buried in the text.
