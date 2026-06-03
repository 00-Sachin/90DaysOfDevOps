Challenge Tasks

Task 1: Your First Script

Create a file hello.sh
Add the shebang line #!/bin/bash at the top
Print Hello, DevOps! using echo
Make it executable and run it 


chmod +x hello.sh
./hello.sh

Hello, DevOps!

Document: What happens if you remove the shebang line?

IF i remove the shebang, the code still executes, as it uses only basic commands like echo 
This works the same for both sh and bash. 

Task 2: Variables

Create variables.sh with:

A variable for your NAME
A variable for your ROLE (e.g., "DevOps Engineer")
Print: Hello, I am <NAME> and I am a <ROLE>

Hey, my name is: sachin
I am 22 years old, and still BEROZGAR

Try using single quotes vs double quotes — what's the difference?

IN my case, I don't see any difference, as I don't use any variable inside a variable 
for ex

introduction='My name is $name and I am $status'
echo $introduction

# Output: My name is $name and I am $status

so don't use single quotes for this type of variable 

Here is a quick, punchy summary of the exact lessons you learned today from troubleshooting your scripts.

Reviewing these will help cement the knowledge so you don't repeat them in your next project!

🧠 What I Learned Today

The Bracket Space Law: You learned that Bash is incredibly sensitive to spacing. Leaving out spaces inside conditional brackets ([[$num == 0]]) treats the entire block as a broken command. You must always write [[ $num == 0 ]].

The read -p Requirement: You discovered that you can't just pass a prompt string directly to the read command. Without the -p flag, Bash treats your prompt text as a variable name and hangs.

The Number vs. String Operator Divide: This is the one that trips up everyone! You learned that -eq, -gt, and -lt are strictly for mathematical numbers, while == and != are strictly for comparing text/strings (like your "y" or "n" responses).

The Power of Strong vs. Weak Quotes: You learned how single quotes ('') act as literal blocks that completely freeze variables from printing, while double quotes ("") allow Bash to dynamically expand your variables (like $name or $status).

Targeted System Checks: You learned how to use specific file-system flags like -f (for regular files) and -d (for directories) to make your automation scripts highly accurate when scanning folders
