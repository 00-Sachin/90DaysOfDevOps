Today’s focus was on automating repetitive tasks using Bash scripting.

I moved beyond single commands and started using programming logic like for loops, while loops, command-line arguments, and basic error handling to make my scripts dynamic and robust.

Task 1: For Loops

Script 1: for_loop.sh

Loops through a predefined list of strings and prints them.

Bash

#!/bin/bash

for fruit in apple banana mango orange berry; do

    echo "$fruit is a fruit"
    
done

Output: Printed the statement for each fruit successfully.

Script 2: count.sh

Uses a numeric range to loop from 1 to 10.

Bash

#!/bin/bash

for i in {1..10}; do

    echo $i
    
done

Output: Counted from 1 to 10 perfectly.

Task 2: While Loop

Script: countdown.sh

Takes user input and counts down to zero.

Bash

#!/bin/bash

read -p "Enter the number from where you want to start the countdown" num

while [ $num -ge 0 ]; do

    echo $num
    num=$((num - 1))
done

echo "done"

Output: Prompted for a number (entered 5), counted down 5, 4, 3, 2, 1, 0, and printed done. 
(Note: I ran into a missing operand error when running chmod initially, 
but quickly fixed it by assigning numeric permissions chmod 744 countdown.sh!)

Task 3: Command-Line Arguments

Script 1: greet.sh

Checks if an argument is passed. If not, it provides usage instructions.

Bash

#!/bin/bash

if [ -z "$1" ]; then

    echo "Usage: ./greet.sh <name>"
    
else

    echo "$1"
fi

Output: Running ./greet.sh triggered the Usage warning. Running ./greet.sh sachin correctly output my name.

Script 2: args_demo.sh

Demonstrates how Bash handles passed arguments natively.

Bash

#!/bin/bash

echo $#

echo $@

echo $0

Output: When passing 2 3 324 534 sachin, the script correctly identified 5 total arguments ($hastag), printed all of them ($@), and printed the script execution name ($0).

Task 4 & 5: Package Installation & Error Handling

Script: install_packages.sh (Combined with root check)

This script checks for root privileges, iterates through a list of packages, and checks their installation status using dpkg.

Bash

#!/bin/bash

# Exit immediately if not run as root

if [ "$EUID" -ne 0 ]; then

    echo "Error: This script must be run as root (or with sudo)."
    exit 1
fi

echo "The list of packegs include nginx, curl, wget"

for pkg in nginx curl wget; do

    echo "checking the status of $pkg"

    if dpkg -s $pkg &> /dev/null; then
    
        echo "$pkg is allready installed"
    else
        echo "Installing $pkg..."
        apt-get install -y $pkg
    fi
done

Output: Running it without sudo successfully triggered my custom error message. Running it with sudo successfully looped through and confirmed nginx, curl, and wget were already installed.

Script: safe_scripts.sh

Practiced using set -e and the || (OR) operator to catch directory creation errors.

Bash

#!/bin/bash

set -e

mkdir /tmp/devops-test || echo "Directory already exists"

cd /tmp/devops-test

touch test_file.txt

Output: Because /tmp/devops-test already existed, the mkdir command threw an error, 
which was elegantly caught by the || operator, printing my custom "Directory already exists" message instead of silently failing.

What I Learned

Validation is Crucial: Adding a simple if [ -z "$1" ] or checking $EUID prevents scripts from running dangerously or failing silently. 
You should always validate inputs and user privileges before executing core logic.

The || Operator is a safety net: Appending || echo "Custom Error" to a command is a brilliant way to handle expected errors (like a folder already existing) without crashing the entire script.

Bash internal variables are powerful: $ isn't just for my own variables. 
Built-in variables like $hastag (count of args), $@ (all args), and $0 (script name) make scripts highly dynamic and adaptable to whatever the user types in the terminal.
