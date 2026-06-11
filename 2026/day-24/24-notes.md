# Day 24 – Advanced Git: Merge, Rebase, Stash & Cherry Pick

## Task 1: Git Merge
### What is a fast-forward merge?
>If you make a new branch, and nobody changes the main branch while you are working, Git doesn't need to do any hard work to merge. It just moves the main pointer forward to catch up with your branch. That is a fast-forward merge.

### When does Git create a merge commit instead?
>If you added commits to your feature branch, AND someone else added new commits to the main branch at the same time, Git has to combine them. It creates a brand new "Merge Commit" to join both histories together.

### What is a merge conflict?
>A conflict happens when you edit the exact same line of the exact same file in two different branches. Git gets confused and basically says, "I don't know which version is the correct one, please fix this manually before I merge."

## Task 2: Git Rebase
### What does rebase actually do to your commits?
>Instead of joining two branches with a messy merge commit, rebase unplugs your feature branch, moves it, and plugs it in at the very tip of the latest main branch.

### How is the history different from a merge?

Merge: Creates a diamond shape in your Git history (git log --graph).

Rebase: Makes your history look like one single, clean, straight line.

### Why should you never rebase commits that have been pushed and shared with others?
>Rebase literally rewrites history and changes the commit IDs (hashes). If you do this to a branch your teammate is also working on, their local Git will get completely out of sync and it will cause massive headaches for them.

### When would you use rebase vs merge?

>Use Merge for shared branches (like bringing a finished feature into main).

>Use Rebase for your own local, private branch to keep it updated with main before you push it.

## Task 3: Squash Commit vs Merge Commit
### What does squash merging do?
When you work on a feature, you might make 10 tiny commits (like "fixed typo", "testing", "fixed again"). Squash merge takes all those messy commits, crushes them into one single, clean commit, and puts that onto main.

### When would you use squash merge vs regular merge?
Use squash merge when your feature branch has a lot of useless, messy commits that you don't want to show in the main project history. Use a regular merge when every single commit is important and tells a story.

### What is the trade-off of squashing?
You get a very clean main branch, but you completely lose the step-by-step history of how you actually built that feature.

### Task 4: Git Stash
### What is the difference between git stash pop and git stash apply?

>git stash pop: Brings your saved work back and deletes it from the stash list.

>git stash apply: Brings your saved work back but keeps a backup copy of it in the stash list just in case.

### When would you use stash in a real-world workflow?
>Imagine you are halfway through writing code for a new feature, and your boss tells you to fix a critical bug on main right now. You can't commit half-written code, and you can't switch branches with unsaved changes. So, you git stash to hide your messy work, switch to main, fix the bug, and then come back and git stash pop to resume your work exactly where you left off. It is a lifesaver.

## Task 5: Cherry Picking
### What does cherry-pick do?
>It lets you pick one specific commit from any branch and copy it into your current branch, without merging the whole thing.

### When would you use cherry-pick in a real project?
>If a teammate fixed a really annoying bug in their feature branch, and you need that exact bug fix in your branch right now, but their feature isn't finished yet. You just cherry-pick their bug fix commit hash.

### What can go wrong with cherry-picking?
>Merge conflicts! I actually faced this today. If the commit you are copying relies on other code that doesn't exist in your branch, Git will throw a conflict. (In my screenshots, you can see I got an error: could not apply and had to abort and try again carefully).
