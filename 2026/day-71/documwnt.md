"""# Ansible Documentation: Roles, Galaxy, and Vault

## 1. What is the difference between `vars/main.yml` and `defaults/main.yml`?

In an Ansible role, both files define variables, but they have fundamentally different purposes based on **Variable Precedence**:

* **`defaults/main.yml` (The Fallback)**
    * **Precedence:** Extremely low (the lowest possible).
    * **Purpose:** These are default values designed to be easily overridden by the user of your role.
    * **Use Case:** Generic configuration settings like default ports (`http_port: 80`), usernames, or optional feature toggles.
* **`vars/main.yml` (The Internal Constants)**
    * **Precedence:** Very high.
    * **Purpose:** These are hard-coded role variables. You put variables here that are essential for the internal mechanics of the role to function correctly. You generally *do not* want the user to override these.
    * **Use Case:** OS-specific package names, internal file paths, or constants used across multiple tasks in the role.

---

## 2. Why use a `requirements.yml` instead of installing roles manually?

While you can install roles manually (e.g., `ansible-galaxy install geerlingguy.nginx`), using a `requirements.yml` file is the standard DevOps best practice for several reasons:

1.  **Infrastructure as Code (IaC):** It creates a single source of truth committed to Git. Anyone cloning your repository knows exactly which dependencies to install.
2.  **Version Pinning:** You can lock roles to specific versions. If the creator updates the role and breaks something, your playbook won't suddenly crash because it's locked to a known working version.
3.  **CI/CD Automation:** Automated pipelines (like GitHub Actions) cannot manually search and install missing roles. They rely on running `ansible-galaxy install -r requirements.yml` to set up the environment automatically.

---

## 3. Why is `--vault-password-file` better than `--ask-vault-pass` for automated pipelines?

* **`--ask-vault-pass`:** This flag prompts a human to physically type the decryption password into the terminal. In an automated CI/CD pipeline (which runs headlessly without human interaction), this will cause the pipeline to hang indefinitely and eventually time out and fail.
* **`--vault-password-file`:** This flag tells Ansible to read the password from a specified text file. In a CI/CD pipeline, you can dynamically inject a secure secret into a temporary file, run the Ansible playbook completely unattended, and then delete the temporary file. This is the only way to achieve true machine-to-machine automation with encrypted secrets.

---

## 4. How to Install and Use a Galaxy Role

### Step 1: Install the Role
You can install a role directly from Ansible Galaxy using the CLI:

```bash
ansible-galaxy role install geerlingguy.docker
---
- name: Setup Web and App Servers
  hosts: app_servers
  become: yes
  roles:
    - geerlingguy.docker
```
## 6. When to use Roles vs Playbooks vs Ad-Hoc Commands

### Ad-Hoc Commands
* **What:** Single-line shell commands using the `ansible` binary.
* **When:** Quick, one-off, temporary tasks (e.g., "Check the uptime of all 50 servers," "Restart Nginx everywhere immediately," or "Check free disk space").
* **Example:** `ansible webservers -m command -a "uptime"`

### Playbooks
* **What:** YAML files mapping out a series of tasks using the `ansible-playbook` binary.
* **When:** Repeatable configuration management, deploying applications, and orchestrating multi-step setups on servers. Playbooks represent your desired state.

### Roles
* **What:** A standardized directory structure for organizing playbooks, variables, files, and templates.
* **When:** When playbooks get too long, or when you want to build a reusable, shareable component (e.g., A "Webserver" role that installs Nginx, configures the firewall, and deploys templates, which you can use across 5 different projects).
