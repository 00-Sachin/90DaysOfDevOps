# Day 42 – Runners: GitHub-Hosted & Self-Hosted

## Task Notes & Learnings

### Task 1: GitHub-Hosted Runners
**What is a GitHub-hosted runner? Who manages it?**
A GitHub-hosted runner is a virtual machine hosted by GitHub with the GitHub Actions runner application pre-installed. It provides a clean, isolated environment for your workflow to run. GitHub entirely manages these runners, meaning they handle the provisioning, maintenance, security patching, and destruction of the VM after the job finishes.

### Task 2: Explore What's Pre-installed
**Why does it matter that runners come with tools pre-installed?**
Having tools like Docker, Python, Node.js, and Git pre-installed saves significant pipeline execution time. If we had to manually install these dependencies during every single workflow run, it would consume extra build minutes and slow down the CI/CD feedback loop.

### Task 5: Labels
**Why are labels useful when you have multiple self-hosted runners?**
Labels allow you to route specific jobs to specific machines. If you have a pool of self-hosted runners, some might have specialized hardware (like GPUs), specific operating systems, or access to internal private networks. By using labels (e.g., `runs-on: [self-hosted, gpu-runner]`), you ensure the job lands on the exact machine equipped to handle it.

---

## Task 6: GitHub-Hosted vs Self-Hosted (Comparison)

| Feature | GitHub-Hosted | Self-Hosted |
| :--- | :--- | :--- |
| **Who manages it?** | GitHub | You (The Developer/Organization) |
| **Cost** | Free for public repos; limited free minutes for private (then pay-per-minute) | Free to connect, but you pay for your own underlying hardware/infrastructure |
| **Pre-installed tools** | Packed with common tools (Docker, Node, AWS CLI, etc.) | None by default (You manage the environment) |
| **Good for** | Standard CI/CD, quick setups, open-source projects | Custom hardware needs, accessing private internal networks, bypassing minute limits on heavy workloads |
| **Security concern** | Very Secure (Ephemeral VMs destroyed after each run) | Higher Risk (Workflows can leave residual files or execute untrusted code on your persistent machine) |

---
