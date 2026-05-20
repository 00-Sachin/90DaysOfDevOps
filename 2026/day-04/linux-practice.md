Day 4 Hands on practice of linux commands

Process Checks


How to check for a particular process?

pgrep -a cron
  888 /usr/sbin/cron -f -P #888 is the PID

what is the command used to check the bussiest processes 

top -n 1  # we use -n 1 for the current time glimpes 
  2399 sachin    20   0  397512  12372   7068 S   8.3   0.1   0:02.55 ibus-da+


System Checks 

Command used to know the helth of a proceses by the system  

systemctl status cron 
## It tells you the detail explantion about that process 

systemctl is-active cron 
## It tell in one word wheather the system is active or not 


Log Checks 

Command used to read the service's diary

journalctl -u cron -n 5 # used to check for a particular services
  May 20 17:35:01 sachin-H510M-K-V2 CRON[4337]: (root) CMD (command -v debian-sa1>
  May 20 17:35:01 sachin-H510M-K-V2 CRON[4336]: pam_unix(cron:session): session c>
  May 20 17:45:01 sachin-H510M-K-V2 CRON[4491]: pam_unix(cron:session): session o>
  May 20 17:45:01 sachin-H510M-K-V2 CRON[4492]: (root) CMD (command -v debian-sa1>
  May 20 17:45:01 sachin-H510M-K-V2 CRON[4491]: pam_unix(cron:session): session c>

Command used to read the general system diary

tail -n 10 /var/log/syslog
  2026-05-20T17:46:40.135011+05:30 sachin-H510M-K-V2 systemd[1]: bluetooth.service - Bluetooth service was skipped because of an unmet condition check (ConditionPathIsDirectory=/sys/class/bluetooth).
  2026-05-20T17:46:42.135821+05:30 sachin-H510M-K-V2 fwupd[4539]: 12:16:42.135 FuMain               fwupd 1.9.34 ready for requests (locale en_US.UTF-8)
  2026-05-20T17:46:42.137093+05:30 sachin-H510M-K-V2 dbus-daemon[863]: [system] Successfully activated service 'org.freedesktop.fwupd'
  2026-05-20T17:46:42.137280+05:30 sachin-H510M-K-V2 systemd[1]: Started fwupd.service - Firmware update daemon.
  2026-05-20T17:46:42.170833+05:30 sachin-H510M-K-V2 systemd[1]: fwupd-refresh.service: Deactivated successfully.
  2026-05-20T17:46:42.170976+05:30 sachin-H510M-K-V2 systemd[1]: Finished fwupd-refresh.service - Refresh fwupd metadata and update motd.
  2026-05-20T17:50:07.078599+05:30 sachin-H510M-K-V2 systemd[1]: Starting sysstat-collect.service - system activity accounting tool...
  2026-05-20T17:50:07.081690+05:30 sachin-H510M-K-V2 systemd[1]: sysstat-collect.service: Deactivated successfully.
  2026-05-20T17:50:07.081777+05:30 sachin-H510M-K-V2 systemd[1]: Finished sysstat-collect.service - system activity accounting tool.
  2026-05-20T17:50:59.521976+05:30 sachin-H510M-K-V2 google-chrome.desktop[3048]: [3041:3041:0520/175059.521196:ERROR:ui/ozone/platform/wayland/host/wayland_data_drag_controller.cc:179] Invalid state when trying to start drag. source=kMouse


Mini Troubleshooting Steps
If you ever check a service and it says inactive or failed, here is the exact sequence to fix it

1.Restart the service:Turning it off and on again fixes 90% of issues.
Run sudo systemctl restart cron

2.Verify it worked:
Run systemctl status cron to make sure it says active (running).

3.Check for errors:If it still fails, 
run journalctl -u cron -e to jump to the very end of the logs and read the red error messages to see exactly what broke.




