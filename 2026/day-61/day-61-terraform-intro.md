# Infrastructure as Code (IaC) - Conceptual Notes

## 1. What is IaC & Why It Matters in DevOps

**Infrastructure as Code (IaC)** is the practice of defining, deploying, and managing IT infrastructure—such as servers, databases, networks, and storage—using machine-readable definition files (like HCL, YAML, or JSON) rather than clicking through a web console or running one-off terminal scripts.

In DevOps, IaC is essential because it treats infrastructure with the same rigor as application software:
* Infrastructure changes are submitted via **pull requests** and peer-reviewed.
* Environments are automatically tested and validated in **CI/CD pipelines**.
* Every change is tracked in **version control** (Git) with a complete audit trail.

---

## 2. Problems IaC Solves vs. Manual AWS Console Work

* **Eliminates Human Error ("ClickOps"):** Manual console setups lead to subtle typos and missed security settings. Code enforces identical, repeatable deployments every time.
* **Prevents Environment Drift:** Guarantees that Dev, Staging, and Production environments share the exact same configuration baseline, eliminating "it worked in staging" failures.
* **Rapid Disaster Recovery:** If an entire cloud region fails, rebuilding manually takes days. With IaC, an entire multi-region architecture can be redeployed in minutes.
* **Living Documentation:** Your codebase serves as an accurate, single source of truth for what resources are actively deployed.

---

## 3. Tool Comparison: Terraform vs. Others

| Tool | Core Focus | Configuration Language | Multi-Cloud Capability |
| :--- | :--- | :--- | :--- |
| **Terraform** | Provisioning | HCL (HashiCorp Configuration Language) | **Cloud-Agnostic** (AWS, GCP, Azure, K8s) |
| **AWS CloudFormation** | Provisioning | JSON / YAML | **AWS Native** |
| **Ansible** | Configuration Management | YAML | Best for configuring software *inside* running servers |
| **Pulumi** | Provisioning | TypeScript, Python, Go, C# | **Cloud-Agnostic** |

---

## 4. Key Concepts

### What "Declarative" Means
In a **declarative** approach, you define the *desired end state*, not the step-by-step commands to get there.

* **Imperative approach:** *"Create an EC2 instance, wait 30 seconds, attach an EBS volume, open port 80."*
* **Declarative approach (Terraform):** *"I need an EC2 instance with an attached EBS volume and port 80 open."*

Terraform reads the current state, compares it against your code, and calculates only the necessary actions required to reach that end state.

### What "Cloud-Agnostic" Means
Terraform is not tied to a specific cloud provider. Through its **provider-based architecture**, you use the same toolchain and core workflow whether you are provisioning resources on AWS, Google Cloud, Azure, or Kubernetes.


# What Happens During `terraform init`?

Running `terraform init` sets up your working environment so Terraform can talk to your cloud provider and run your code.

## 1. What got downloaded?

* **Provider Plugins:** The actual binary code (translators) for the services you're using—like the AWS, GCP, or Azure plugin. These translate your HCL code into API calls to the cloud provider.
* **Modules:** Copies of any reusable code modules you referenced in your configuration (from GitHub or the Terraform Registry).
* **Backend Drivers:** The necessary code to talk to your state storage (like an AWS S3 bucket), if you configured one.

---

## 2. What's inside the `.terraform/` directory?

Think of the hidden `.terraform/` folder as a **local cache**. Inside, you'll find:

* **`providers/`**: The plugin binaries Terraform downloaded to manage your resources.
* **`modules/`**: Downloaded module files and a `modules.json` manifest mapping them to your code.
* **Environment/State metadata:** Files tracking your active workspace and backend connection settings.

> **Tip:** Never commit `.terraform/` to Git! It contains large, system-specific binary files. Always list it in your `.gitignore`.

# How Terraform Knows What to Create (State & Plan)

When you run `terraform apply`, Terraform doesn't guess what to build—it checks two sources of truth: your **state file** (`terraform.tfstate`) and the **real-world cloud infrastructure**.

Here is how it figures out that the S3 bucket already exists and only the EC2 instance needs to be created:

## 1. It checks the `terraform.tfstate` file
Terraform maintains a hidden tracking ledger called the **state file**. 
* When you previously created the S3 bucket, Terraform recorded its unique ID, attributes, and resource mapping in `terraform.tfstate`.
* Before making changes, Terraform reads this file to see what resources it previously created and is currently managing.

## 2. It refreshes real-world infrastructure
Terraform calls the AWS API to perform a **refresh**. It inspects the actual S3 bucket in your AWS account to verify it still exists and check its current settings against what is recorded in the state file.

## 3. It calculates the "Delta" (The Execution Plan)
Terraform compares three things:
1. **Your Code** (*Desired state*: S3 Bucket + EC2 Instance)
2. **The State File** (*Known state*: S3 Bucket recorded)
3. **AWS Real World** (*Actual state*: S3 Bucket exists)

Since the S3 bucket exists in all three places, Terraform marks it as **unchanged**. Since the EC2 instance is in your code but *missing* from the state file and AWS, Terraform concludes:
> *"The bucket is already good to go. I only need to issue an API call to create the EC2 instance."*

---

> **Key Takeaway:** Terraform relies on its **state file** to track managed resources and compares it against your **code** to determine exactly what needs to be created, updated, or destroyed.

# Understanding the Terraform State File (`terraform.tfstate`)

The state file is the backbone of Terraform. It acts as a single source of truth mapping your code to real-world cloud resources. Here is a breakdown of what it stores and how to safely manage it.

---

## 1. What Information Does the State File Store?

For every resource defined in your code, the state file stores:

* **Resource Metadata & Bindings:** Maps your local code names (e.g., `aws_instance.web`) to real cloud unique IDs (e.g., `i-0a1b2c3d4e5f6g7h8`).
* **Resource Attributes & Properties:** Complete configuration details returned by the cloud API after creation—including calculated attributes not written in your code (e.g., private/public IP addresses, MAC addresses, ARN strings, and creation timestamps).
* **Dependencies:** Tracks implicit and explicit relationships between resources so Terraform knows the correct order to create, update, or destroy them.
* **Sensitive Values:** Sensitive outputs or provider data (such as auto-generated passwords, private keys, database connection strings, and IAM tokens).

---

## 2. Why Should You Never Manually Edit the State File?

* **Risk of State Corruption:** The state file is formatted in precise JSON. A single typo, misplaced bracket, or invalid attribute name will break Terraform's ability to read the file, rendering your workspace unusable.
* **Loss of Resource Tracking (Orphaned Resources):** If you manually delete or alter a resource's metadata, Terraform will lose track of it. This can lead to duplicate resources being created or, worse, Terraform accidentally destroying the wrong live infrastructure.
* **Race Conditions & Desync:** Manually tweaking values bypasses Terraform's built-in dependency checks and lock mechanisms, causing the actual cloud state and state file to fall out of sync.

> **Safe Alternative:** Always use built-in CLI commands to modify state safely:
> * `terraform state list` — View tracked resources.
> * `terraform state mv` — Rename or move resources in state.
> * `terraform state rm` — Remove a resource from state management without deleting it in the cloud.
> * `terraform import` — Bring existing real-world resources into state.

---

## 3. Why Should the State File NOT Be Committed to Git?

* **Exposes Unencrypted Secrets:** The state file stores **all resource attributes in plain text**. This includes database passwords, API tokens, TLS private keys, and SSH keys. Committing it to a Git repository exposes those credentials to anyone with read access.
* **Merge Conflicts & State Corruption:** If multiple team members make changes simultaneously, Git will attempt to merge conflicting JSON lines. Merging state files manually almost always results in corrupted JSON or overwritten infrastructure tracking.
* **Concurrence & Race Conditions:** Git is designed for code collaboration, not real-time state locking. It cannot prevent two developers from applying changes at the exact same moment.

> **Best Practice:** Always use a **Remote Backend** (such as AWS S3 with DynamoDB locking, Terraform Cloud, or Azure Blob Storage) with encryption at rest enabled and state locking turned on. Add `*.tfstate` and `*.tfstate.backup` to your `.gitignore` file.

# Reading the `terraform plan` Output

When you run `terraform plan`, Terraform gives you a preview of the changes it is about to make. It uses a simple symbol system to show you exactly what will happen.

## 1. What do the symbols mean?

* **`+` (Green): Create** — Terraform is going to build a brand new resource.
* **`-` (Red): Destroy** — Terraform is going to delete this resource.
* **`~` (Yellow): Update in-place** — Terraform will modify an existing resource without tearing it down.

## 2. How to spot In-Place vs. Destroy-and-Recreate

You can tell exactly how a modification will be handled by looking closely at the plan output:

* **In-Place Update (`~`):** 
  If you only see the yellow `~`, the resource stays online. Terraform is just tweaking a setting (like adding a tag or changing a description) without interrupting the resource.

* **Destroy and Recreate (`-/+`):** 
  If you see a red minus and a green plus together (`-/+`), Terraform is forced to replace the resource. It will delete the existing one and build a fresh one. This happens when you change a foundational setting that the cloud provider won't let you change on the fly (like changing the region of an S3 bucket or the base AMI of an EC2 instance).

# day-61-terraform-intro.md

## 1. What is Infrastructure as Code (IaC)?
Infrastructure as Code (IaC) is the practice of building and managing IT resources—like servers, networks, and databases—using configuration files instead of clicking through a web interface. By writing our infrastructure as code, we can track changes in Git, peer-review deployments, and automate environment setups just like we do with application software. This eliminates human error from manual configurations and ensures our staging and production environments are identical, repeatable, and fast to recover.

---

## 2. Core Terraform Commands

Here is a quick reference for the daily Terraform workflow:

* **`terraform init`**: Prepares your working directory. It downloads the necessary provider plugins (like the AWS translator) and sets up your local cache so Terraform can execute your code.
* **`terraform plan`**: The "dry run." It compares your code to the real world and shows you a blueprint of what it will do (Create `+`, Update `~`, or Destroy `-`) without actually changing anything yet.
* **`terraform apply`**: Executes the plan. This command actually makes the API calls to your cloud provider to build, update, or tear down your real-world infrastructure.
* **`terraform destroy`**: The cleanup command. It reads your state file and safely deletes every single resource managed by this specific project.
* **`terraform show`**: Prints out a human-readable summary of exactly what is currently deployed based on your state file, or inspects a saved plan.
* **`terraform state list`**: Outputs a simple, quick list of all the resource names that Terraform is currently tracking in your state file.

---

## 3. The State File (`terraform.tfstate`)

### What it contains:
The state file is a JSON ledger that acts as Terraform's memory. It maps the resources written in your code to the actual unique IDs of the resources running in AWS. It stores all the metadata, relationships, and generated attributes (like public IP addresses or auto-generated passwords) that the cloud provider returns after a resource is created.

### Why it matters:
Terraform relies entirely on the state file to figure out what to do next. When you run a plan, Terraform compares your code against this file and the real world to calculate the "delta"—identifying exactly what needs to be added, changed, or removed. Without the state file, Terraform would lose track of your infrastructure and blindly try to recreate everything from scratch every time you run it.
