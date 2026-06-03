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
