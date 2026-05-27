Day 10 Challenge: File Creation, Viewing, and Numeric Permissions
Today was all about mastering file manipulation and getting comfortable with numeric (octal) permissions. 
It is really satisfying to see how quickly you can lock down or open up access to a file once you understand the math behind chmod! 
(I even used tail to verify that my users from yesterday's Money Heist-themed challenge are still sitting safely in /etc/passwd!)

Here is the breakdown of today's hands-on lab.

Files Created

devops.txt: Created as an empty file using touch.

notes.txt: Created directly from the command line using echo and redirection.

script.sh: A simple executable bash script created using vim.

project/: A dedicated directory created with specific permissions right from the start.

Permission Changes

I practiced using numeric values to change access rights:

script.sh: Started as -rw-rw-r-- (664). Changed to -rwxrw-r-- (chmod 764) 
to give myself (the owner) execution rights so the script could actually run.

devops.txt: Started as -rw-rw-r-- (664). Changed to -r--r--r-- (chmod 444) 
to make it strictly read-only for absolutely everyone.

notes.txt: Started as -rw-rw-r-- (664). Changed to -rw-r----- (chmod 640) 
to give myself read/write access, my group read access, and lock out "others" entirely.


Commands Used

# Setting up the workspace and creating files
mkdir day10
cd day10
touch devops.txt
echo "This file is created directly using echo command" > notes.txt

# Creating a script and making it executable
vim script.sh
ls -l
chmod 764 script.sh
. script.sh  # Executed the script which printed "Hello DevOps"

# Viewing file contents and system users safely
cat notes.txt
vim -R script.sh  # Opened the script in Read-Only mode to avoid accidental edits!
head -n 5 /etc/passwd
tail -n 5 /etc/passwd  # Verified my users (tokyo, berlin, etc.) from Day 9!

# Modifying permissions using numbers
chmod 444 devops.txt
chmod 640 notes.txt

# Creating a directory with permissions already set
mkdir -m 755 project/
ls -l

What I Learned

Numeric chmod is a time-saver: Using numbers (4=read, 2=write, 1=execute) is so much faster than typing out chmod u+x,g-w etc. 
figuring out that 764 means (4+2+1 for owner, 4+2 for group, 4 for others) makes permission management click instantly.

One-Step Directory Creation: I didn't realize you could set permissions while creating a folder. 
Using mkdir -m 755 creates the directory and sets the exact access rights in a single command, which is perfect for automation scripts.

Safe viewing with Vim: Using vim -R opens a file in read-only mode. 
This is a brilliant trick for DevOps when you need to inspect a critical production script 
or config file but want to guarantee you don't accidentally type something and break it!

