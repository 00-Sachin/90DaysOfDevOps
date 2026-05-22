Day 6: Linux Fundamentals – Read and Write Text Files
File: file-io-practice.md

Today’s focus is on manipulating text files directly from the command line. Instead of opening a text editor, I used basic input/output redirection to create, write, and read files.

1. Creating the File
Command: touch notes.txt

What it did: Created a completely empty file named notes.txt. (If the file already existed, it would just update the "last modified" timestamp without changing the actual text).

2. Writing Text (The Dangerous Way)
Command: echo "Line 1: Starting my Linux file practice." > notes.txt

What it did: The single > symbol is a redirect. It took the text from echo and pushed it into the file.

Note: A single > will overwrite everything currently in the file. It is a destructive command!

3. Appending Text (The Safe Way)
Command: echo "Line 2: Appending this line so I don't lose Line 1." >> notes.txt

What it did: The double >> safely added this new text to the very bottom of the file without deleting the first line.

4. Writing and Viewing Simultaneously
Command: echo "Line 3: Using tee is pretty cool." | tee -a notes.txt

What it did: The tee command splits the output like a "T" junction in a pipe. It printed the text to my terminal screen and safely appended it (-a) to the file at the same time.

5. Reading the Full File
Command: cat notes.txt

What it did: Read and displayed the entire content of the file in the terminal. I could see all three of my lines perfectly.

6. Reading Parts of the File
Command: head -n 2 notes.txt

What it did: Displayed only the top 2 lines of the file. This is great for peeking at the beginning of huge files without flooding the terminal screen.

Command: tail -n 2 notes.txt

What it did: Displayed only the bottom 2 lines of the file. This is exactly what I would use to check the most recent entries at the very end of a system log file.

7. Command used to do both at same time 

   tee: it works as echo "This line will print on terminal as well as saved in a file" | tee -a /var/location-of-file.txt

   
