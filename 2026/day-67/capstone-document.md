# TerraWeek Capstone: Project Summary & Q&A

## 1. Terraform Workspaces Q&A

**Q: What does `terraform.workspace` return inside a config?**
**A:** It returns a string representing the name of the currently active Terraform workspace you are using (e.g., "dev", "staging", or "prod").

**Q: Where does each workspace store its state file?**
**A:** By default, when using a local backend, each workspace stores its state file in a hidden directory structured as `terraform.tfstate.d/<workspace-name>/terraform.tfstate`. *(Note: `terraform.tfstate` in the root folder is only for the "default" workspace).*

**Q: How is this different from using separate directories per environment?**
**A:** Using separate directories means you have to constantly copy and paste the exact same infrastructure code into multiple folders, which is hard to manage. Workspaces allow you to use **one** unified codebase to spin up multiple isolated environments just by switching the workspace and passing different `.tfvars` files.

**Q: Why is the file structure used in this project considered best practice?**
**A:** Because it follows a logical flow of data and strictly separates concerns. By splitting code into `main.tf`, `variables.tf`, and `outputs.tf`, and moving repeatable resources into the `modules/` folder, the codebase becomes clean, scalable, and highly reusable. It also ensures sensitive files are safely ignored via `.gitignore`.

---

## 2. Project Directory Structure

```text
terraweek-capstone/
├── .gitignore
├── dev.tfvars
├── locals.tf
├── main.tf
├── outputs.tf
├── prod.tfvars
├── providers.tf
├── staging.tfvars
├── variables.tf
└── modules/
    ├── ec2-instance/
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── security-group/
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    └── vpc/
        ├── main.tf
        ├── outputs.tf
        └── variables.tf
```

---

## 3. Terraform Best Practices Guide

* **File structure:** Separate files for providers, variables, outputs, main, and locals.
* **State management:** Always use a remote backend, enable state locking, and enable versioning.
* **Variables:** Never hardcode values. Use `.tfvars` per environment and validate with validation blocks.
* **Modules:** Keep one concern per module, always define inputs/outputs, and pin registry module versions.
* **Workspaces:** Use workspaces for environment isolation and reference `terraform.workspace` in configs.
* **Security:** Use `.gitignore` for state and tfvars, encrypt state at rest, and restrict backend access.
* **Commands:** Always run `terraform plan` before `apply`, and use `fmt` and `validate` before committing code.
* **Tagging:** Tag every resource with project, environment, and managed-by labels.
* **Naming:** Use a consistent prefix pattern like `<project>-<environment>-<resource>`.
* **Cleanup:** Always run `terraform destroy` on non-production environments when they are not in use.

---

## 4. TerraWeek Concepts Review

| Day | Key Concepts Learned |
| :--- | :--- |
| **61** | IaC, HCL, init/plan/apply/destroy, state basics |
| **62** | Providers, resources, dependencies, lifecycle |
| **63** | Variables, outputs, data sources, locals, functions |
| **64** | Remote backend, locking, import, drift |
| **65** | Custom modules, registry modules, versioning |
| **66** | EKS with modules, real-world provisioning |
| **67** | Workspaces, multi-env deployments, capstone project |