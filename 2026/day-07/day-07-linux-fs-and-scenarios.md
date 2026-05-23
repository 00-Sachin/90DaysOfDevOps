1. Linux File System Hierarchy

"/" :   This is the root directory it is the topmost level of the entire file system hierarchy
        it contains various major directories/files within it like "boot" "bin" "etc" "home" and much more.
        i would use this directory when i have to figure out anything about the system

"/home" : This is a dedicated, private space for each user account 
          It contains the name of the users using your system
          I would use this directory when i have to search for any users 

"/root" : It is the home directory of the admin  
          It contanis admin dedicated things 
          NOrmal user can't open this directory 

"/etc"  :  It is the central hub for system-wide configuration files
           It contains all the files that describes or tells the operating system how to perform "ssh" "cron" 
           I will use this directory when i have to check any deep information about any process

"/var/log" : This directory is very essential in linux as it saves the record of everything that happens in your                    system 
              it contains "boot" "config" "syslog"
              this will often used widely by me to check for any faults

"/tmp"      : As the name suggest it stores only the  temprory files that are created by users, os, procesees. 
              It shows folders for different application like for the chrome "com.google.Chrome.DLjzx0"
              I will use it to store my temporary files. 

"/bin"      : Contains essential system binaries required for the system to boot and run in single-user mode. 
              it also contains foundational commands here like ls, cp, and mv .
              I will use this directory when i have to check for any boot related quaaries 

"/usr/bin"   :  Stores the majority of user-accessible programs that are not critical for basic system booting, such                  as python, git, or text editors

"/opt"       : It stores all the information about the third party apps that are installed in your system
               i saw the directory of chrome where many information are stored 
               i used this to see for any third party application 

Hands On Task
                
Command used to check the top 5 biggest file in your log folder

"du -sh /var/log/* 2>/dev/null | sort -h | tail -5" : 

breif explanation: du : used to chechk the free space 
                   -sh : these flags used to summerize && human readable form 
                   /var/log/* : In this * tells to chek the complete log directory
                   2> : used to pass all the unwanted error
                   /dev/null : a black hole 
                   sort -h : sort the data into human readable form small to big 
                   tail -5 : prints the last 5 lines of teh output 


"cat /etc/hostname": Prints your computer hostname

"ls -la ~" : shows all the hidden files in the home directory that starts with . 

2. Scenario Practice

   The Dead Service. A service named myapp didn't start after a reboot.
           step1 : systemctl status myapp : check the current status of the app.
           step2 : journalctl -u myapp -n 10 : It shows the most recent activity of myapp
           step3 : systemctl is-enabeld myapp : it checks the system trias to start it

   Scenario 2: The Sluggish Server. The server is slow and the CPU is spiking.
           step1: htop : to see which processes takes more cpu percentage and fetch thier PID
           step2 : kill -9 <PID> : It terminate the processes

   Scenario 3: The Missing Logs. A developer needs the logs for the docker service.
            step1 : journalctl -u docker : It gives all the requierd logs related to docker

   Scenario 4: The Blocked Script. A script at /home/user/backup.sh says "Permission denied".
             step1 : ls -l : To check the permmison of that backup.sh
             step2 : chmod 777 : It changes the permission to allow everthing to everyone ("NOte it is risky gave                          permission accordingly")
