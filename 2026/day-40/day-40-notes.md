# GitHub Actions & CI/CD Guide

## 1. The Core Concept: What is CI/CD in this context?
By writing this workflow, you transition from running code locally to automating execution in the cloud. **GitHub Actions** acts as your automated assistant, spinning up a fresh computer (a "Runner") every time an event occurs (like a push), running your predefined scripts, and shutting down.

## 2. Anatomy of a Workflow (YAML Syntax Breakdown)
Understanding the `.github/workflows/*.yml` file is about understanding the hierarchy of how GitHub Actions executes tasks.

* **`name`**: The human-readable name of your pipeline. This is what shows up in the GitHub Actions UI.
* **`on` (The Trigger)**: Defines when this workflow should run. Using `on: [push]` means any push to any branch will trigger a run. Other common triggers include `pull_request` or `schedule` (like a cron job).
* **`jobs` (The Work to do)**: A workflow consists of one or more jobs. Jobs run in parallel by default. In our task, we only had one job named `greet`.
* **`runs-on` (The Runner / Environment)**: Tells GitHub what operating system to boot up for this job. `ubuntu-latest` is the most common and cheapest (if you are on billing). It provisions a fresh Ubuntu Linux Virtual Machine in Microsoft Azure for your job.
* **`steps` (The Instructions)**: The sequential list of tasks the runner will execute. *Important:* Steps inside the same job share the same file system and run one after the other.
* **`uses` (Pre-built Actions)**: Calls a reusable, pre-written piece of code. `uses: actions/checkout@v4` is the most crucial step in almost every pipeline. Why? Because a GitHub runner starts as a completely empty machine. It doesn't automatically have your repository's code on it. The checkout action downloads your code onto that runner so subsequent steps can interact with your files.
* **`run` (Shell Commands)**: Executes raw shell/terminal commands on the runner (e.g., `echo`, `ls -la`, `npm install`, `python script.py`).
* **`name` (Step Level)**: Labels the step in the GitHub UI. If you don't provide a name, GitHub will just use the raw command as the label, which can make logs messy and hard to read.

## 3. GitHub Contexts and Variables
In Task 4, you used syntax like `${{ github.ref_name }}`.

* **The `${{ ... }}` syntax**: This is called *expression syntax*. It tells GitHub to evaluate what is inside the brackets before running the command, injecting dynamic data.
* **`github.` context**: Contains information about the workflow run and the event that triggered it (e.g., `github.ref_name` gives the branch name, `github.actor` gives the username of the person who pushed).
* **`runner.` context**: Contains information about the VM executing the job (e.g., `runner.os` returns `Linux`, `Windows`, or `macOS`).

## 4. Pipeline Failures and Debugging (Task 5)
When you purposely broke the pipeline (e.g., by adding a step with `run: exit 1` or a typo like `echho "Hello"`), you triggered a CI failure.

### What a failure looks like:
* A red "X" appears next to your commit hash in the repository.
* You may receive an email notification that the workflow failed.
* In the Actions tab, the workflow run is marked in red.

### The Chain Reaction:
If Step 2 fails, Steps 3, 4, and 5 are skipped automatically. A job immediately halts at the first step that returns a non-zero exit code (an error).

### How to read the error:
1. Navigate to the **Actions** tab.
2. Click the failed run.
3. Click on the specific job on the left-hand menu.
4. Look for the step expanded in red.
5. Read the raw console output. It will tell you exactly what the shell experienced (e.g., `bash: echho: command not found` or `Error: Process completed with exit code 1`).

## 5. Key Takeaways from Day 40
* Workflows must live in `.github/workflows/` – if they are placed anywhere else, GitHub will ignore them.
* YAML relies on indentation. A misplaced space can break the whole file. Always ensure your steps are indented properly under your jobs.
* Runners are ephemeral. They boot up, run your code, and are destroyed. Any files created during a job (that aren't explicitly saved or uploaded as artifacts) disappear when the pipeline finishes.
