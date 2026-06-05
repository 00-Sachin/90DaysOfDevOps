
Task 1: Basic Functions

Script: function.sh

Created a script with two functions: one to greet a user and one to add two numbers.

Bash

#!/bin/bash

  greet() {
  
      read -p "enter your name : " name
      echo "hello, $name"
  }
  
  add() {
      
      read -p "Enter the first number.." num1
      read -p "Enter the second number.." num2
      echo "adding $num1 and $num2"
      sum=$((num1+num2))
      echo $sum
  }

greet

add

Output: The script successfully prompted for my name, then prompted for 21 and 21, returning 42.

Task 2: Functions with Outputs

Script: disk_check.sh

Packaged system commands into labeled functions.

Bash

#!/bin/bash

check_disk() {

    echo ""
    echo "THE DISK STATUS IS..."
    df -h /
}

check_memory() {

    echo ""
    echo "AND THE FREE MEMORY USING ARE .."
    free -h
}

check_disk

check_memory

Output: Cleanly executed both blocks, showing my /dev/sda5 disk usage and 15Gi total memory.

Task 3: Strict Mode (set -euo pipefail)

I tested what happens when you intentionally break a script. Without strict mode, Bash tries to keep going. With strict mode, it stops the bleeding immediately.

Explanation of the flags:

set -e (Exit on error): If any command returns a non-zero exit code (meaning it failed), the script stops immediately. 
In my test, when the typo command cet failed, the script exited before it could print "i hope you will find this".

set -u (Undefined variables): If you try to use a variable that hasn't been created yet, the script throws an error and stops. This prevents disasters like rm -rf /$EMPTY_VAR translating to rm -rf /.

set -o pipefail: By default, if you run a piped command like cat badfile.txt | grep "error", Bash only looks at the exit code of the last command (grep). If cat fails, Bash still thinks the whole line succeeded. pipefail forces the whole pipe to fail if any piece of it fails.

Task 4: Local Variables

Variables inside Bash functions are global by default, meaning a function can accidentally overwrite a system variable. I tested this by comparing a leaky function to a safe function using the local keyword.

Bash

#!/bin/bash

# Inside a function:

local name="sachin"

echo "my name is $name"

Observation: By declaring local name=sachin, the variable ceases to exist the moment the function finishes running,
keeping the rest of the script's global state safe and untouched!

Task 5: Build a Script — System Info Reporter

Script: system_info.sh

Built a comprehensive, modular script using everything learned today.

Bash
#!/bin/bash
set -euo pipefail

os_info() {

    echo "......................................"
    echo "Hostname and OS info"
    echo "......................................"
    hostnamectl
}

uptime_status() {

    echo "--Checking System Uptime Status-----"
    command uptime
}

disk_usage() {

    echo "------------------------------------"
    echo "Disk Usage (Top 5 Commands)"
    echo "------------------------------------"
    df -h | sort -hr | head -n 5
}

mem_usage() {

    echo "------------------------------------"
    echo "Ram Usage (Top 5 Commands)"
    echo "------------------------------------"
    free -h
}

cpu_usage() {

    echo "------------------------------------"
    echo "Cpu Usage info"
    echo "------------------------------------"
    top -b -n 1 | head -n 12 | tail -n 6
}

main() {

    echo "calling the main function"
    os_info
    uptime_status
    disk_usage
    mem_usage
    cpu_usage
}

main
Output: A beautifully formatted, multi-section dashboard reporting exactly what is happening on my Ubuntu environment, driven entirely by one single main function call at the bottom.

What I Learned

Functions create cleaner architectures: Wrapping commands in functions like cpu_usage() and grouping them in a main() block makes the code 10x easier to read and troubleshoot than a massive top-to-bottom list.

set -euo pipefail is mandatory: I will never write a production Bash script without this at the top. Failing fast and loudly is infinitely better than a script silently doing the wrong thing.

Always use local in functions: To prevent strange bugs where variables overwrite each other, any variable declared inside a function should use the local keyword unless it specifically needs to be accessed globally.
