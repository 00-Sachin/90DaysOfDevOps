Day 11 Challenge: File & Directory Ownership


Today’s focus was on understanding how Linux manages ownership.
I continued with my Money Heist team setup to practice changing user and group owners using chown and chgrp.
I also ran into some real-world troubleshooting with permissions and file paths!

Files & Directories Created


day-11-file-ownership.md (Notes file)

devops-file.txt

team-notes.txt

project-config.yaml

app-logs/ (Directory)

heist-project/ (Directory containing plans/strategy.conf and vault/gold.txt)

bank-heist/ (Directory containing access-codes.txt, blueprints.pdf, and escape-plan.txt)


Ownership Changes


I practiced passing ownership of files and folders to different users and groups:

devops-file.txt: sachin:sachin → tokyo:sachin → berlin:sachin

team-notes.txt: sachin:sachin → sachin:heist-team

project-config.yaml: sachin:sachin → professor:heist-team

app-logs/: sachin:sachin → berlin:heist-team

heist-project/ (and all contents): sachin:sachin → professor:planners

bank-heist/access-codes.txt: sachin:sachin → tokyo:vault-team

bank-heist/blueprints.pdf: sachin:sachin → berlin:tech-team

bank-heist/escape-plan.txt: sachin:sachin → nairobi:vault-team

Commands Used


# Basic User Ownership

touch devops-file.txt
sudo chown tokyo devops-file.txt
sudo chown berlin devops-file.txt

# Group Ownership

touch team-notes.txt
sudo groupadd heist-team
sudo chgrp heist-team team-notes.txt

# Changing Both User and Group Simultaneously

touch project-config.yaml
sudo chown professor:heist-team project-config.yaml
mkdir app-logs/
sudo chown berlin:heist-team app-logs

# Recursive Ownership Changes

sudo groupadd planners
sudo chown -R professor:planners heist-project
ls -lR heist-project

# Troubleshooting Paths & Typos

sudo groupadd vault-team
sudo groupadd tech-team
mkdir bank-heist
touch bank-heist/access-codes.txt bank-heist/blueprints.pdf bank-heist/escape-plan.txt

pwd # Used to find my exact absolute path (/home/sachin/day11)

sudo chown tokyo:vault-team /home/sachin/day11/bank-heist/access-codes.txt
sudo chown berlin:tech-team /home/sachin/day11/bank-heist/blueprints.pdf
sudo chown nairobi:vault-team /home/sachin/day11/bank-heist/escape-plan.txt

What I Learned

sudo is mandatory for ownership changes: Even if you are the one who created the file, 
Linux will block you with an "Operation not permitted" error if you try to give it away or change its group without using sudo.

The magic of the -R flag: When working with folders (like the heist-project directory), using chown -R is incredibly efficient.
It recursively applies the new ownership to the main folder and every single file/folder nested inside of it in one go.

Paths and Typos will trip you up: I spent some time troubleshooting "No such file or directory" and "invalid user" errors. 
I learned that putting a / before a folder name (/bank-heist) tells Linux to look at the absolute root of the system, not the folder
I am currently sitting in.Using pwd to grab the absolute path fixed my issue instantly, 
and it was a great reminder to double-check my spelling (nariobi vs. nairobi)!
