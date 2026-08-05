# Day 68: Introduction to Ansible

## Ansible Architecture (In My Own Words)
At its core, Ansible is an automation engine that keeps things incredibly simple by being **agentless**. Unlike tools like Chef or Puppet that require you to install special software (agents) on every server you want to manage, Ansible relies entirely on standard SSH (or WinRM for Windows). 

The architecture is built around a few key components:
1. **Control Node:** The machine where Ansible is installed. This is where you run your commands and playbooks. It needs Python installed.
2. **Managed Nodes:** The target servers you are managing. They just need Python and an SSH connection—Ansible pushes tiny pieces of code (modules) to these nodes, executes them, and then removes them.
3. **Inventory:** A list of your managed nodes. Ansible uses this file to know *where* to run its tasks.
4. **Modules:** The actual units of work (e.g., "start a service", "create a file", "install a package"). You call modules via playbooks or ad-hoc commands.

## Lab Setup Details
For this lab, I provisioned the infrastructure using **Terraform** on AWS to ensure the environment is reproducible.

**Instance Details:**
* **Provider:** AWS (us-east-1)
* **OS:** Ubuntu 22.04 LTS (AMI: ami-0c7217cdde317cfec)
* **Instance Type:** `t3.micro`
* **Nodes Created:**
  * `ansible-control-node` (Where Ansible is installed)
  * `web-server-01` (Managed Node)
  * `db-server-01` (Managed Node)

After Terraform finished provisioning, I generated an SSH key pair on the `ansible-control-node` and copied the public key to the `authorized_keys` file of both managed nodes to enable passwordless SSH authentication.

## Inventory File (`inventory.ini`)
Here is the static inventory file I created to organize my managed nodes. 

```ini
[webservers]
web-server-01 ansible_host=xx.xx.xx.105 ansible_user=ubuntu

[dbservers]
db-server-01 ansible_host=xx.xx.xx.212 ansible_user=ubuntu

[all:vars]
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_python_interpreter=/usr/bin/python3


# Ansible Core Concepts and Architecture

## What is configuration management? Why do we need it?
Configuration Management is the process of maintaining servers, software, and infrastructure in a desired, consistent state. While provisioning tools (like Terraform) *create* the infrastructure, Configuration Management tools (like Ansible) *configure* what runs on them (installing software, managing files, and starting services). 

We need it to automate repetitive tasks, eliminate human error ("configuration drift"), and save massive amounts of time. Ansible achieves this beautifully through its agentless architecture, push-based model, and readable YAML-based playbooks.

## How is Ansible different from Chef, Puppet, and Salt?
* **Architecture:** Ansible is **agentless** and uses a **push** model (it pushes configurations out from a central machine). Chef, Puppet, and Salt traditionally require you to install an agent (background software) on every single server, and they use a **pull** model (the agents periodically ask the master server for updates).
* **Language:** Ansible uses easy-to-read **YAML**. Chef uses Ruby, Puppet uses its own proprietary DSL (Domain Specific Language), and Salt uses a mix of Python and YAML.
* **Simplicity:** Ansible has the lowest barrier to entry because it relies on standard SSH and doesn't require complex certificate or agent setups.

## What does "agentless" mean? How does Ansible connect to managed nodes?
"Agentless" means you do not need to install any background software, daemons, or Ansible-specific agents on the managed nodes. 

Ansible uses standard **SSH** (Secure Shell) to connect to Linux nodes (and WinRM for Windows). Once connected via SSH, it pushes tiny pieces of **Python** code (modules) to the managed nodes, executes them to configure the system, and then deletes the code. So, it *connects* via SSH, but *requires* Python installed on the target machine to execute the work.

## Ansible Architecture
Here is how the pieces fit together:
* **Control Node:** The machine where Ansible runs (in this case, your laptop).
* **Managed Nodes:** The servers Ansible configures (your EC2 instances).
* **Inventory:** The list of managed nodes (usually an `inventory.ini` or YAML file).
* **Modules:** The units of work Ansible executes (e.g., install a package, copy a file, start a service).
* **Playbooks:** YAML files that define what to do on which hosts. They stitch modules together into repeatable routines.

## Documentation: Lab Setup
**On which machine did you install Ansible? Why is it only needed on the control node?**
I installed Ansible on my local system, which serves as the Control Node to manage all my AWS EC2 instances from a single location. Ansible is only needed on this control node because of its agentless architecture; it simply reaches out to the target instances over standard SSH connections to push configurations, meaning the EC2 instances only need SSH access and Python installed to be managed.