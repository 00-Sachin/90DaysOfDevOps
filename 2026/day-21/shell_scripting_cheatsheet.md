| **Variable** | `VAR="value"` | `NAME="DevOps"` |

| **Argument** | `$1, $2` | `./script.sh arg1` |

| **If Condition** | `if [ condition ]; then` | `if [ -f file.txt ]; then` |

| **For Loop** | `for i in list; do` | `for i in 1 2 3; do` |

| **Function** | `name() { ... }` | `greet() { echo "Hi"; }` |

| **Grep** | `grep pattern file` | `grep -i "error" log.txt` |

| **Awk** | `awk '{print $1}' file` | `awk -F: '{print $1}' /etc/passwd` |

| **Sed** | `sed 's/old/new/g' file` | `sed -i 's/foo/bar/g' config.txt` |


# 1. Basics

Shebang (#!/bin/bash)
Tells the computer which program to use to run the script. Always put this on the very first line.

Bash: - 
#!/bin/bash

Running a Script
First, give the file permission to run, then execute it.

Bash: - 
chmod +x script.sh

./script.sh

Comments: - Notes that we can see. The computer ignores them.

Bash: - 
#This is a full-line comment

echo "Hello" # This is an inline comment

Variables: -
Store data to use later. Do NOT put spaces around the = sign.

Bash: -
NAME="Sachin"

echo "My name is $NAME"  # Prints: My name is Sachin

echo 'My name is $NAME'  # Single quotes print exact text: My name is $NAME

Reading User Input

Ask the user to type something and save it as a variable.

Bash:-  read -p "Enter your age: " AGE

echo "You are $AGE years old."

# Command-Line Arguments

Read values passed directly after the script name (e.g., ./script.sh apple orange).

$0: The name of the script itself.

$1, $2: The first and second words passed.

$#: Total count of words passed.

$@: All words passed as a single list.

$?: Result (exit code) of the last command run.

# 2. Operators and Conditionals

# String Comparisons (Checking text)

=: Matches exactly.

!=: Does not match.

-z: String is empty (zero length).

-n: String is NOT empty.

Bash: -- 
if [ "$NAME" = "Sachin" ]; then echo "Match!"; fi

# Integer Comparisons (Checking numbers)

-eq: Equal to

-ne: Not equal to

-lt: Less than

-gt: Greater than

-le: Less than or equal to

-ge: Greater than or equal to

Bash:----if [ $AGE -gt 18 ]; then echo "Adult"; fi

# File Test Operators (Checking files/folders)

-f: Is it a normal file?

-d: Is it a folder (directory)?

-e: Does it exist at all?

-r, -w, -x: Does the user have Read, Write, or Execute permission?

-s: Is the file NOT empty (has some size)?

Bash:-----if [ -f "/tmp/test.txt" ]; then echo "File exists!"; fi

If, Elif, Else

Make decisions in your code based on conditions.

Bash

if [ $NUM -gt 10 ]; then

    echo "Big"
elif [ $NUM -eq 10 ]; then
    
    echo "Exact"
else
    
    echo "Small"
fi

# Logical Operators

&& (AND): Both sides must be true.

|| (OR): One side must be true.

! (NOT): Flips the result.

Bash

if [ -f "file.txt" ] && [ -s "file.txt" ]; then
    
    echo "File exists AND is not empty."
fi

# Case Statements

A cleaner way to check a variable against many options.

Bash

case $FRUIT in

    "apple") echo "It's red" ;;
    "banana") echo "It's yellow" ;;
    *) echo "Unknown fruit" ;; # The * acts like "else"
esac

# 3. Loops

For Loop:--Run a piece of code a specific number of times.

Bash

#List-based

for color in red blue green; do
    
    echo "$color"
done

#C-style number range

for i in {1..5}; do
   
    echo "Number $i"
done

While Loop:---Keep running the code as long as the condition is true.

Bash

COUNT=1

while [ $COUNT -le 3 ]; do

    echo "Count is $COUNT"
    COUNT=$((COUNT + 1))
done

Until Loop:---Keep running the code until the condition becomes true.

Bash

until [ -f "ready.txt" ]; do
    
    echo "Waiting for file..."
    sleep 2
done

# Loop Control

break: Stop the loop completely and exit it.

continue: Skip the rest of this current round and go to the next one.

# Looping Over Files

Quickly do something to every file in a folder.

Bash
for file in /var/log/*.log; do

    echo "Found log: $file"
done

Looping Over Command Output

Read output line by line (great for reading text files).

Bash
cat names.txt | while read line; do

    echo "Processing $line"
done

# 4. Functions

Defining and Calling

Group commands together so you can reuse them later.

Bash

#Define it

say_hello() {

    echo "Hello there!"
}

#Call it

say_hello

Passing Arguments

Functions use their own $1 and $2, completely separate from the script's $1.

Bash

greet_user() {

    echo "Hello, $1!"
}

greet_user "Sachin" # Passes Sachin as $1

Return Values vs. Echo

return only passes back a number code (0-255) for success/fail. Use echo to pass back actual text.

Bash

get_status() {

    return 0 # Means success
}
Local Variables
Use local so the variable does not accidentally break things outside the function.

Bash

math_task() {
    
    local RESULT=42
    echo $RESULT
}

# 5. Text Processing Commands

grep (Search for text)

-i: Ignore capital letters.

-r: Search inside all folders.

-c: Just count the matches.

-n: Show the line number.

-v: Show lines that do NOT match.

Bash

grep -i "error" server.log

awk (Print specific columns)

Great for splitting lines of text. $1 is the first column, $2 is the second.

Bash

#Split by spaces and print column 2

awk '{print $2}' file.txt 

sed (Find and replace)


s/old/new/g: Swap 'old' with 'new' globally on that line.

-i: Save the changes directly to the file.

Bash

sed -i 's/IP/192.168.1.5/g' config.conf

cut (Extract parts of a line)

-d: What character splits the words?

-f: Which chunk do you want?

Bash:--cut -d':' -f1 /etc/passwd # Gets a list of usernames

Other Quick Tools

sort: Sorts lines A-Z. (sort -nr sorts numbers highest to lowest).

uniq -c: Groups matching lines together and counts them.

tr 'a' 'b': Changes all 'a' letters to 'b'.

wc -l: Counts total lines in a file.

head -n 5: Shows the top 5 lines.

tail -f: Shows the bottom lines and watches live as new lines are added.

# 6. Useful Patterns and One-Liners

1. Find and delete files older than 30 days


Bash:---find /backup -name "*.tar.gz" -type f -mtime +30 -delete

2. Count lines in all .log files

Bash:---wc -l *.log

3. Replace a word inside multiple files at once

Bash:--sed -i 's/localhost/127.0.0.1/g' *.conf

4. Check if a service (like Nginx) is running

Bash:---ps aux | grep "[n]ginx" || echo "Nginx is DOWN!"

5. Watch a log file live and filter only for Errors

Bash:---tail -f /var/log/syslog | grep -i "error"

# 7. Error Handling and Debugging

Exit Codes ($?)

Every command leaves a secret number behind when it finishes. 0 means success. Anything else means an error.

Bash

ping -c 1 google.com

if [ $? -eq 0 ]; then echo "Internet is working"; fi

Strict Mode Flags (Put these at the top of your script)

set -e: Stops the script instantly if any command fails.

set -u: Stops the script if you try to use an empty/undefined variable.

set -o pipefail: Stops the script if any part of a chained | command fails.

Bash

#!/bin/bash

set -euo pipefail

Debug Mode (set -x)

Prints every single command to your screen right before it runs. Perfect for finding where a script is breaking.

Bash

set -x # Turn debug on

echo "Testing"

set +x # Turn debug off

Trap

Tells the script to do a specific task right before it exits or crashes (like deleting temporary junk files).

Bash

trap 'echo "Script finished, cleaning up..."; rm -f /tmp/junk.txt' EXIT
