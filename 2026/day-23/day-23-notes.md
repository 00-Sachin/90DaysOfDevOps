# Day 23 – Git Branching & Working with GitHub


## Task 1: Understanding Branches

### What is a branch in Git?

> A branch is like a separate workspace. It lets you make a copy of the code, work on it, and make changes without touching the main project.

### Why do we use branches instead of committing everything to main?
> We use branches to keep the main (or master) code safe. If we make a mistake while adding a new feature, it only breaks the branch, not the working main code. Once the branch is perfect, we can merge it into main.

### What is HEAD in Git?
>HEAD is just a marker or a pointer. It tells Git which branch or commit you are currently looking at and working on right now.

### What happens to your files when you switch branches?
>The files in your computer folder physically change. Git updates the files in your folder to look exactly how they did in the branch you just switched to.

## Task 2: Branching Commands

(I have updated my git-commands.md file with these new commands)

git branch (Lists all branches)

git branch <name> (Creates a new branch)

git checkout <name> (Switches to a branch)

git checkout -b <name> (Creates and switches to a new branch at the same time)

git switch <name> (A newer, simpler command just for switching branches)

git branch -d <name> (Deletes a branch)

## Task 3: Push to GitHub

### What is the difference between origin and upstream?

>Origin: This is the link to your own repository on GitHub. When you push code, it goes here.

>Upstream: This is the link to the original repository created by someone else (used when you fork a project).

## Task 4: Pull from GitHub

### What is the difference between git fetch and git pull?

>git fetch: This talks to GitHub and downloads the latest updates, but it does NOT change the files on your computer. It just lets you see what is new.

>git pull: This downloads the latest updates from GitHub AND immediately updates the files on your computer to match.

## Task 5: Clone vs Fork
### What is the difference between clone and fork?

>Fork: This is a GitHub button. It copies someone else's project into your own GitHub account online.

>Clone: This is a Git command. It copies a repository from GitHub down to your actual computer so you can work on the files.

### When would you clone vs fork?

>You clone when you want to work on a project you already own, or if you just want to download files to look at them.

>You fork when you want to make changes to someone else's public project. You fork it to your account first, then clone it to your computer, make changes, and ask them to accept your changes later.

### After forking, how do you keep your fork in sync with the original repo?
>You add the original person's repository link as an "upstream" remote. Then, you use a command like git pull upstream main to get their latest updates into your copy.
