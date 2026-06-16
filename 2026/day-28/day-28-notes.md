# Day 28 – Revision Day: Everything from Day 1 to Day 27


## 🔄 Task 1 & 2: Self-Assessment & Re-learning Weak Spots

Today was all about taking a step back and plugging the gaps in my knowledge. I went through the checklist and identified a few areas where I needed a quick refresher. I spent today completely mastering these topics:

- **Linux File System Hierarchy:** Reviewed the purposes of core directories (`/etc` for configs, `/var` for variable data like logs, `/tmp` for temporary files, etc.).
- **LVM (Logical Volume Management):** Revisited how to create and manage Physical Volumes (PV), Volume Groups (VG), and Logical Volumes (LV).
- **Network Connectivity Tools:** Practiced using `ping`, `curl`, `netstat`, `ss`, `dig`, and `nslookup` to diagnose network and DNS issues.
- **Shell Scripting Logic:** Re-wrote scripts using `case` statements and `until` loops to get the syntax deeply ingrained in my muscle memory.
- **Crontab Syntax:** Re-memorized the `* * * * *` format (Minute, Hour, Day of Month, Month, Day of Week).

---

## ⚡ Task 3: Quick-Fire Questions

*Note: I struggled with questions 2, 6, and 9 during my initial self-assessment. I have researched and provided the correct answers below so I never forget them!*

**1. What does `chmod 755 script.sh` do?** It gives the owner Read, Write, and Execute permissions (`7`), and gives the group and others Read and Execute permissions (`5`).

**2. ❌ [Initially got this wrong] What is the difference between a process and a service?** A process is any running instance of a program (like running `ls` or a `python` script). A service (or daemon) is a background process managed by the system (like `systemd`) that runs continuously without direct user interaction (like `nginx` or `sshd`).

**3. How do you find which process is using port 8080?** By running `sudo ss -tulpn | grep 8080` or `sudo netstat -tulpn | grep 8080`.

**4. What does `set -euo pipefail` do in a shell script?** It enables strict mode: `-e` exits on error, `-u` exits on undefined variables, and `-o pipefail` fails the script if any command in a piped chain fails.

**5. What is the difference between `git reset --hard` and `git revert`?** `git reset --hard` deletes the commit history and destroys your working directory changes. `git revert` safely creates a brand new commit that undoes the previous changes, preserving history.

**6. ❌ [Initially got this wrong] What branching strategy would you recommend for a team of 5 developers shipping weekly?** GitHub Flow. It is lightweight, uses a single `main` branch, relies on Pull Requests for features, and is perfect for small, agile teams that ship fast.

**7. What does `git stash` do and when would you use it?** It temporarily hides your uncommitted changes. You use it when you are halfway through working on a file but urgently need to switch branches to fix a bug without committing broken code.

**8. How do you schedule a script to run every day at 3 AM?** `0 3 * * * /path/to/script.sh`

**9. ❌ [Initially got this wrong] What is the difference between `git fetch` and `git pull`?** `git fetch` just downloads the latest updates from GitHub so you can see them, but it doesn't change your local files. `git pull` downloads the updates AND immediately merges them into your current files.

**10. What is LVM and why would you use it instead of regular partitions?** LVM pools physical hard drives together into a virtual volume. You use it because it allows you to dynamically resize, extend, or shrink storage partitions on the fly without system downtime.

---

## 📋 Task 4: Organization Checklist

- [x] All daily submissions pushed to GitHub.
- [x] `git-commands.md` updated with GitHub CLI (`gh`) commands.
- [x] Shell scripting cheat sheet completed.
- [x] GitHub profile README and repositories organized.

---

## 🧑‍🏫 Task 5: Teach It Back

### Explaining Crontab (Why SysAdmins Love It)

You can call the crontab a scheduler. Why I am saying this is because it saves a lot of time for system admins by running the same processes at exact times automatically. Doing this manually is tough to follow every single day; we are humans, sometimes we forget, and that is not good for an organization.

Suppose you are a system admin, your company does not allow you to use crontab, and you are assigned various tasks—one of them being to take a backup of files at 10 PM every day. Think how bad it is when you are finally spending your time relaxing with family, and then you suddenly realize, *"Ohhh, I have to run a script for backup."* The whole moment gets spoiled! 

Crontab saves you from manually running scripts, protects your personal time, and automates the heavy lifting.
