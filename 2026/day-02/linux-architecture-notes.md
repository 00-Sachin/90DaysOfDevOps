Day 2  Today’s goal is to understand how Linux works.

Short notes:

The core components of Linux (kernel, user space, init/systemd)

Kernel: Think of it as the brain. It allocates resources ("CPU," "RAM," "Disk") to various processes for a specific amount of time.
It can directly communicate with the hardware of the system and is also known as the core of Linux.

User Space: This is the space where all applications, programs, and shells (like Bash) run. 
Because they cannot directly interact with the hardware, they do so with the help of the kernel.

init/systemd: It is the very first process that starts after your system boots Linux, and its PID is always 1. 
It acts like a parent process that sets up your system to work.



How processes are created and managed

Processes are simply a running instance of a program.
IN Linux we have 2 ways to create a process, 1st one is fork() "clone the current processes" 2nd exec() "REplace the clone with the new program" 

To manage these processes we use its different states 

Running (R): The process is actively executing on the CPU or is in the queue ready to execute.

Sleeping (S / D): The process is resting, waiting for an event or resource.
Interruptible (S): Waiting for user input or a timer.
Uninterruptible (D): Deep sleep, usually waiting on disk or network I/O.

Stopped (T): The process has been suspended or paused (e.g., by pressing Ctrl+Z in the terminal).

Zombie (Z): The process has finished executing and is dead, but its parent process hasn't checked its exit status yet. 
It is essentially a "ghost" lingering in the process table.



What systemd does and why it matters

systemd is kind of a modern system and service manager for Linux. 
It boots the system, manages background services, and handles logging.

It amtters because it allows services to start in parallel (making boots faster), automatically restarts crashed applications, and it is a primary tool for diagnosing
why a web server or database failed to launch.



5 Daily Commands for DevOps

ps aux: provdide the information about the current running processes and who owns them 
top: It shows the live details of running processes in a more interactive way
kill -9 <PID>: kills the frozen or dead process forcefully
systemctl status <service_name>: it checks the background runing processes details like nginx, docker etc.
journalctl -u <service_name>: Reads the specific logs for a systemd service. This is the first stop when an application fails to start.
