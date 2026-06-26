# Day 39 – What is CI/CD?

## ⚠️ Task 1: The Problem (Manual Deployments)

Imagine a team of 5 developers pushing code manually to the same production server:

* **What can go wrong?** Human error is inevitable. Someone might overwrite another developer's changes, forget to install a new dependency, or copy the wrong configuration file. This leads to broken applications, severe downtime, and unhappy users.
* **What does "it works on my machine" mean and why is it a real problem?** It means the code runs perfectly on a developer's local laptop, but crashes in production. This happens because the developer's laptop and the production server have different operating systems, library versions, or environment configurations. *(This is exactly the problem Docker solves!)*
* **How many times a day can a team safely deploy manually?** Very few. Realistically, a team might safely deploy once a week or maybe once a day, but it will be highly stressful, slow, and prone to burnout.

* ## 🔄 Task 2: CI vs CD

* **Continuous Integration (CI):** The practice of developers frequently merging their code changes into a central repository (multiple times a day). Automated builds and tests run immediately to catch bugs early before the code is ever deployed. 
  * *Example:* Every time a developer opens a Pull Request on GitHub, a system automatically runs unit tests to make sure they didn't break existing features.
* **Continuous Delivery (CD):** An extension of CI where the code is always perfectly built, tested, and ready to be deployed to production. However, the final deployment still requires a human to click an "Approve" or "Deploy" button.

* * *Example:* The marketing team wants to release a new website feature precisely on Friday at 9 AM, so the engineering manager manually clicks "Deploy" when the time comes.
* **Continuous Deployment (CD):** Goes one step further than Delivery. Every single code change that passes the automated tests goes straight into production automatically, with zero human intervention. 
  * *Example:* A Netflix or Amazon engineer pushes a code fix, and 15 minutes later, it is automatically live for millions of users because it passed all automated safety checks.

---
## 🧬 Task 3: Pipeline Anatomy

* **Trigger:** The specific event that kicks off the pipeline (e.g., a code push, a pull request, or a scheduled timer).
* **Stage:** A logical grouping of jobs representing a phase in the pipeline (e.g., the "Build" stage or the "Deploy" stage).
* **Job:** A specific unit of work that executes inside a stage (e.g., "Run Python Tests").
* **Step:** A single command or action inside a job (e.g., `npm install` or `docker build`).
* **Runner:** The actual virtual machine or server that executes the jobs in the pipeline.
* **Artifact:** The final file or output produced by a job that can be used by other stages (e.g., a compiled `.jar` file or a built Docker image).

---

## 🎨 Task 4: Draw a Pipeline

Here is a text-based pipeline diagram for the scenario: **Push Code -> Test -> Build Docker Image -> Deploy to Staging**.

```text
[ Trigger: Git Push to Main Branch ]
               |
               v
+-----------------------------+
|       STAGE 1: TEST         |
|-----------------------------|
| Job: Unit Tests             |
| Step 1: Checkout Code       |
| Step 2: Install Python deps |
| Step 3: Run PyTest          |
+-----------------------------+
               |
         (Tests Pass)
               |
               v
+-----------------------------+
|       STAGE 2: BUILD        |
|-----------------------------|
| Job: Docker Build & Push    |
| Step 1: Login to DockerHub  |
| Step 2: docker build -t app |
| Step 3: docker push app     |
+-----------------------------+
               |
         (Image Pushed)
               |
               v
+-----------------------------+
|       STAGE 3: DEPLOY       |
|-----------------------------|
| Job: Deploy to Staging      |
| Step 1: SSH into Server     |
| Step 2: Pull new image      |
| Step 3: Restart Containers  |
+-----------------------------+

```

---
## 🌍 Task 5: Explore in the Wild

I explored the official GitHub repository for **FastAPI** (a popular Python web framework). 
**Target File:** `.github/workflows/test.yml`

* **What triggers it?** It triggers on a `push` to the `master` branch and on any `pull_request`.
* **How many jobs does it have?** It has multiple jobs, primarily the `test` job which runs as a matrix across different operating systems.
* **What does it do?** It automatically checks out the code, sets up multiple different versions of Python (3.8 through 3.12), installs all necessary dependencies, and runs testing scripts to ensure the framework is highly stable before any new code is merged.
