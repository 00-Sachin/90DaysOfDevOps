# Day 64 -- Terraform State Management and Remote Backends

## Task 1: Inspect Your Current State

I applied the configuration from Day 63 (containing resources like VPC, subnets, EC2 instances, etc.) and inspected the state using `terraform state list` and `terraform state show`.

**Answers:**
* **How many resources does Terraform track?** 
  Terraform tracks all resources defined in the `.tf` files and created in the cloud. Based on the state list, it tracks resources like `aws_vpc`, `aws_subnet`, `aws_instance`, `aws_security_group`, `aws_route_table`, etc. 
* **What attributes does the state store for an EC2 instance?** 
  It stores significantly more than just the attributes defined in the configuration. It tracks the `arn`, `private_ip`, `public_ip`, `mac_address`, `security_groups`, `subnet_id`, `root_block_device` configurations, and AWS-assigned IDs.
* **What does the serial number represent in `terraform.tfstate`?** 
  The serial number is an incrementing integer that tracks the version of the state file. Every time Terraform modifies the state, the serial number increases. Terraform uses this to prevent older state files from overwriting newer ones.

---

## Task 2: Set Up S3 Remote Backend

Storing state locally poses high risks (data loss, lack of collaboration). I configured an S3 backend with DynamoDB locking.

1. Created an S3 bucket (`terraweek-state-sachin`) with versioning enabled.
2. Created a DynamoDB table (`terraweek-state-lock`) with a `LockID` partition key.
3. Added the `backend "s3"` block to `terraform.tf`.
4. Executed `terraform init` to migrate the state. 


### Diagram: Local State vs. Remote State Setup

**Local State Setup:**
```text
[ Developer's Laptop ]
   |-- main.tf
   |-- terraform.tfstate  <-- State stored locally. Risk of loss/corruption.
   `-- AWS Cloud (Infrastructure)
```
```text
[ Developer 1 ] -------.
                       |    [ AWS Cloud ]
                       |---> (S3 Bucket: terraform.tfstate)  <-- Central Source of Truth
                       |---> (DynamoDB: LockID)              <-- Prevents concurrent applies
[ Developer 2 ] -------'
```
## Task 3: Test State Locking

To test DynamoDB locking, I ran `terraform apply` in Terminal 1 and simultaneously ran `terraform plan` in Terminal 2.


### Answers:

**What is the error message?**
`Error: Error acquiring the state lock... ConditionalCheckFailedException.`

**Why is locking critical for team environments?**
It prevents two developers (or CI/CD pipelines) from modifying the infrastructure at the exact same time. Without locking, concurrent applies would corrupt the remote state file, leading to untracked infrastructure or catastrophic destructive changes.

---

## Task 4: Import an Existing Resource

I manually created an S3 bucket named `terraweek-import-test-sachin` via the AWS CLI/Console and imported it into my Terraform state.

Command executed:
```bash
terraform import aws_s3_bucket.imported terraweek-import-test-sachin
```
### Answers:

**What is the difference between terraform import and creating a resource from scratch?**
Creating a resource from scratch tells Terraform to provision the actual physical resource in the cloud and simultaneously add it to the state. terraform import takes a resource that already exists in the cloud and maps it to a resource block in your Terraform state without provisioning anything new.


## Task 5: State Surgery — `mv` and `rm`

*   **State `mv`:** I used `terraform state mv aws_s3_bucket.imported aws_s3_bucket.logs_bucket` to rename the resource within the state file.
*   **State `rm`:** I used `terraform state rm aws_s3_bucket.logs_bucket` to tell Terraform to "forget" the resource without actually destroying the bucket in AWS.

### Answers:

**When would you use `state mv` in a real project?**  
When you are refactoring your code (e.g., renaming a poorly named resource block, or moving a resource into a module) and want to update the state mapping without tearing down and recreating the actual cloud resource.

**When would you use `state rm`?**  
When you want to stop managing a resource with Terraform but want to leave it running. For instance, passing ownership of a database to a different team or tool without risking accidental deletion.

---

## Task 6: Simulate and Fix State Drift

State drift occurs when reality (AWS) diverges from the Terraform configuration.

1. I manually went into the AWS console and changed the "Name" tag of my EC2 instance to `ManuallyChanged`.
2. When I ran `terraform plan`, Terraform correctly identified the drift and proposed changing it back to the configured name (`dev-dev-server`).

3. I ran `terraform apply` to reconcile the drift, forcing the infrastructure back to my desired configuration. A subsequent `terraform plan` showed *No changes*.

### Answers:

**How do teams prevent state drift in production?**  
Teams prevent state drift by completely restricting write access to the AWS Console/CLI for developers. All infrastructure changes must be enforced strictly through a CI/CD pipeline using Terraform. Additionally, scheduling automated drift-detection runs (e.g., nightly `terraform plan`) alerts the team if manual changes bypassed the pipeline.

---

## Reference Guide: When to use what

*   **`terraform state mv`**: Use to rename a resource block in code or move it into a module without destroying the real cloud resource.
*   **`terraform state rm`**: Use to remove a resource from Terraform's tracking without deleting the actual resource from the cloud provider.
*   **`terraform import`**: Use to bring existing infrastructure (created manually or by other tools) under Terraform management.
*   **`terraform force-unlock`**: Use only if a Terraform run crashed or lost connection and left a stale lock in DynamoDB, and you are 100% sure no one else is currently running an apply.
*   **`terraform refresh` (or `apply -refresh-only`)**: Use to safely update the state file with the current real-world status of the infrastructure without making any provisioning changes.