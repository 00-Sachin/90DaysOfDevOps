# Day 26 - GitHub CLI Complete Notes

Here are my full notes for the Day 26 GitHub CLI challenge, covering everything from Task 1 to Task 6. I've included the actual commands I ran and some mistakes I fixed along the way based on my terminal output.

## Task 1: Install and Authenticate

Getting logged in was straightforward using `gh auth login`. I chose the web browser option. Later on, when I tried to delete a repository in Task 2, I found out I didn't have the right permissions. I had to run `gh auth refresh -h github.com -s delete_repo` to get a new one-time code and grant my CLI permission to delete repos. 

**Answer to the challenge question:**
* **What authentication methods does `gh` support?**
  It supports authenticating through the web browser (which gives you a one-time code) or by pasting in a Personal Access Token (PAT) that you generate in your GitHub developer settings.

---

## Task 2: Working with Repositories

I tested out managing my repositories entirely from the command line. Here are the commands I used:

* **Create a repo:** `gh repo create my-test-repo --public --add-readme`
* **Clone a repo:** `gh repo clone 00-Sachin/Git-Practice`
* **View repo details:** `gh repo view 00-Sachin/Git-Practice`
* **List my repos:** `gh repo list` (This showed my 5 repos, like `90DaysOfDevOps` and `shell-scripts`)
* **Open in browser:** `gh repo view 00-Sachin/Git-Practice --web`
* **Delete a repo:** `gh repo delete 00-Sachin/git-cli-repo --yes`

*Note: As mentioned in Task 1, the delete command threw an HTTP 403 error at first until I refreshed my auth token with the `delete_repo` scope.*

---

## Task 3: Issues

I practiced managing issues without opening the GitHub website. I actually ran into a GraphQL error at first because I typed my username wrong (`Sachin` instead of `00-Sachin`), but it worked perfectly once I fixed it.

Here are the commands:
* **Create an issue:** `gh issue create --repo 00-Sachin/Git-Practice --title "Bug: Login button broken" --body "The login button does not respond on mobile devices." --label "bug"`
* **List issues:** `gh issue list --repo 00-Sachin/Git-Practice`
* **View an issue:** `gh issue view 2 --repo 00-Sachin/Git-practice`
* **Close an issue:** `gh issue close 2 --repo 00-Sachin/Git-practice`

**Answer to the challenge question:**
* **How could you use `gh issue` in a script or automation?**
  You could write a script that automatically runs `gh issue create` if a backup fails or a server goes down, alerting the team right away. You can also use the `--json` flag to pull a list of open bugs into a daily report.

---

## Task 4: Pull Requests

I tested creating a pull request straight from the terminal. I made a change to my README, committed it, and then ran the PR create command. I noticed I had some uncommitted changes during the process, but it still worked and opened the comparison page right in my browser session. Afterwards, when I ran `gh pr list`, I could see my open pull request (PR #3) sitting there. 

Here are the commands I used:
* `git checkout -b feature-gh-cli-test`
* `git commit -am "docs: update README via gh cli"`
* `gh pr create --title "docs: update README via gh cli" --body "Testing GitHub CLI" --web`
* `gh pr list`
* `gh pr status`
* `gh pr merge` (to merge the PR when ready)

**Answers to the challenge questions:**
* **What merge methods does `gh pr merge` support?**
  It supports the normal three ways to merge:
  1. Standard merge commit (`--merge` or `-m`)
  2. Rebase and merge (`--rebase` or `-r`)
  3. Squash and merge (`--squash` or `-s`)

* **How would you review someone else's PR using `gh`?**
  I would do it in three steps:
  1. Pull their branch to my machine to test it: `gh pr checkout <pr-number>`
  2. Look at the code changes: `gh pr diff`
  3. Leave my review or approve it: `gh pr review <pr-number> --approve -b "Looks good to me!"`

---

## Task 5: GitHub Actions & Workflows (Preview)

I haven't gone deep into GitHub Actions yet, but I tried out the commands to see how they work.

* `gh run list` - shows a list of the recent workflow runs.
* `gh run view` - lets you pick a specific run and see its status or logs.

**Answer to the challenge question:**
* **How could `gh run` and `gh workflow` be useful in a CI/CD pipeline?**
  It makes debugging way faster. If my code fails a pipeline test, I don't need to open my browser, log into GitHub, and click through menus to find the error. I can just type `gh run view` in the terminal to see exactly what failed. You can also manually start a pipeline from the terminal using `gh workflow run`.

---

## Task 6: Useful gh Tricks

I explored some extra commands and added these to my personal git commands list:

* **`gh api user`**: Grabs my user data directly from the GitHub API.
* **`gh gist create script.sh --public`**: A really fast way to share a piece of code as a public Gist.
* **`gh release create v1.0.0 --notes "Initial release"`**: Creates a new project release.
* **`gh alias set pv "pr view"`**: Lets me make my own short commands so I type less.
* **`gh search repos "devops"`**: Finds repositories on GitHub without needing to use the website search bar.
