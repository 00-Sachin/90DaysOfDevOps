# TerraWeek Day 65: Terraform Modules Documentation

## 1. Core Concepts

### What is the difference between a "root module" and a "child module"?
*   **Root Module:** This is the primary directory where you execute Terraform commands (`terraform init`, `plan`, `apply`). It serves as the main entry point and orchestrator for your infrastructure, calling upon other modules to provision resources.
*   **Child Module:** A separate, reusable block of Terraform code located in another directory (either locally or in a remote registry). It is called by a root module (or another child module) and cannot be applied directly on its own.

### Where does Terraform download registry modules to?
When you run `terraform init`, Terraform downloads any modules referenced from the public or private Terraform Registry into a hidden directory within your root project folder:
`./.terraform/modules/`

---

## 2. Five Module Best Practices
1.  **Strictly Version Control External Modules:** Always use version constraints (like `version = "~> 5.0"`) for registry modules to prevent automated updates from breaking your infrastructure with incompatible changes.
2.  **Embrace the Single Responsibility Principle:** Keep modules highly focused on a specific task (e.g., creating a standalone EC2 instance or a distinct networking layer) rather than building massive, complex "do-everything" modules.
3.  **Make Everything Parameterized:** Avoid hardcoding values (like AMI IDs, names, or instance sizes) inside the module. Pass them in as variables so the module remains 100% reusable across different environments.
4.  **Expose Important Attributes:** Always define `outputs.tf` in your child modules to pass resource IDs, IP addresses, and ARNs back up to the root module, enabling cross-module referencing.
5.  **Always Document Your Modules:** Include a `README.md` in every custom module directory detailing the purpose, required inputs, default values, and available outputs so other engineers can easily consume it.

---

## 3. Custom Module Structure

Here is the standard directory tree for a Terraform project using local child modules:

```text
terraform-modules/
├── main.tf                    # Root module - calls child modules
├── variables.tf               # Root variables
├── outputs.tf                 # Root outputs
├── providers.tf               # Provider config
└── modules/
    ├── ec2-instance/          # Custom EC2 Child Module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── security-group/        # Custom Security Group Child Module
        ├── main.tf
        ├── variables.tf
        └── outputs.tf

```
# Comparison: Hand-written VPC vs. Registry VPC Module

| Feature | Hand-Written VPC | Registry VPC Module (`terraform-aws-modules/vpc/aws`) |
| :--- | :--- | :--- |
| **Code Length** | Typically 150–300+ lines of code. | ~15 lines of code. |
| **Components Managed** | Requires explicitly defining every resource: VPC, Internet Gateway, Subnets, Route Tables, NAT Gateways, Elastic IPs, and Route Table Associations. | Abstracted. Generates all underlying components dynamically based on simple variable lists (like `public_subnets = [...]`). |
| **Complexity** | **High.** Easy to miss a route table association or place a NAT gateway in the wrong subnet, leading to connectivity issues. | **Low.** It automatically handles routing logic, AZ distribution, and NAT gateway attachments securely and efficiently based on best practices. |
