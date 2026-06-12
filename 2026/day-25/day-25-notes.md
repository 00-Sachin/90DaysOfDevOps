# Day 25 – Git Reset vs Revert & Branching Strategies


## Task 1: Git Reset (Undoing Mistakes)
I practiced making 3 commits and using different reset commands. Here is what I observed:

> git reset --soft: This is used to undo the commit and place the changes back into the staging area. NOTE: It does not delete your actual file changes; it just undoes the commit step so you can add more things or change the message.

> git reset --mixed: (This is the default if you just type git reset). This undoes the commit AND pulls everything out of the staging area. Your file changes are still there on your computer, but they are now untracked/unstaged.

> git reset --hard: This one is serious. It undoes the commit from the record permanently AND it throws away the actual changes in your files. Your files go back to exactly how they looked at the previous commit.

### Answers:

> Which one is destructive and why? --hard is destructive because it deletes your uncommitted working directory changes. If you haven't backed up that code, it is gone!

> When would you use each one? * Use --soft when you just want to edit your last commit message or add one missed file to it.

> Use --mixed when you want to un-commit and un-stage things to review your code again.

> Use --hard when your code is completely messed up and you want to throw it all in the trash and start fresh from the last commit.

> Should you ever use git reset on pushed commits? NO! It rewrites history. If your team has already downloaded that commit and you delete it from history, it will cause huge conflicts for everyone.

## Task 2: Git Revert
I made 3 commits (X, Y, Z) and used git revert on the middle one (Y).

### Answers:

> What happens? It does an awesome thing: it undoes the code changes you created in commit Y, but it does not delete commit Y from the history. Instead, it creates a brand new commit that says "Revert Y".

> How is git revert different from git reset? reset goes back in time and erases history. revert moves forward by creating a new commit that acts like an "undo button" for a past mistake.

> Why is revert considered safer? Because it keeps the history intact. If you push code to GitHub and realize it has a bug, using revert is safe because it won't mess up your teammates' local history.

> When to use which? Use reset for mistakes on your own private, local computer. Use revert for mistakes that have already been pushed to the public GitHub repository.

| Topic                            | git reset                                       | git revert                                            |
|----------------------------------|-------------------------------------------------|-------------------------------------------------------|
| What it does?                    | Erases a commit and moves the pointer backward. | Creates a new commit that reverses a previous change. |
| Removes commit from history?     | YES                                             | NO                                                    |
| Safe for shared/pushed branches? | NO (Never do this)                              | YES (Best practice)                                   |
| When to use?                     | Local, un-pushed mistakes.                      | Public, already-pushed mistakes.                      |

## Task 4: Branching Strategies
 How real engineering teams manage their code:

### 1. GitFlow

How it works: A very strict and heavy model. You have a main branch (for production) and a develop branch. Features branch off from develop. When ready, develop goes to a release branch, and finally to main.

Flow: Feature -> Develop -> Release -> Main. (Plus Hotfix branches directly to Main for emergencies).

Pros/Cons: Great for strict control, but very slow and complex.

### 2. GitHub Flow

How it works: Very simple. There is only one rule: the main branch must always be deployable. You create a feature branch off main, test it, open a Pull Request, and merge it straight back to main.

Flow: Main -> Feature Branch -> Pull Request -> Main.

Pros/Cons: Fast and simple, but requires strong automated testing.

### 3. Trunk-Based Development

How it works: Developers don't make long-living feature branches. Everyone pushes their small, daily code updates directly to the main branch (the "trunk"). They use "feature flags" to hide unfinished features from users.

Pros/Cons: Super fast collaboration, no merge conflicts, but requires highly skilled teams and intense testing.

## Answers:

Which strategy for a fast-shipping startup? GitHub Flow or Trunk-Based Development. It lets them push code quickly.

Which strategy for a large team with scheduled releases? GitFlow. It is safe, structured, and allows for formal testing before a big launch.

Open-source projects? Most open-source projects (like React or Linux) use a variation of GitHub Flow combined with Forking.
