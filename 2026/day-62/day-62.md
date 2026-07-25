# Day 62: Providers, Resources, and Dependencies 🚀

Until today, I've mostly been creating standalone resources. But in the real world, cloud infrastructure is deeply connected. A server lives inside a subnet, which lives inside a VPC, which relies on a route table and an internet gateway to talk to the outside world. 

Today, I built a complete, fully connected AWS networking stack from scratch and learned how Terraform is smart enough to figure out the exact order to build things. Here's a breakdown of my tasks and what I learned.

---

## Task 1: Exploring the AWS Provider

I started by creating a new directory `terraform-aws-infra` and setting up my `providers.tf` file. I pinned the AWS provider to version `~> 5.0`. 

**What I learned about versioning:**
* **`~> 5.0` (Pessimistic Constraint):** This is the sweet spot. It tells Terraform to accept any minor or patch updates (like 5.1, 5.2), but *never* upgrade to 6.0. This keeps things updated but prevents breaking changes.
* **`>= 5.0`:** This would allow *any* version above 5.0, including major releases like 6.0 or 7.0. It's a bit risky for production.
* **`= 5.0.0`:** This pins it strictly to one exact version. Safe, but you miss out on bug fixes.

**What is that `.terraform.lock.hcl` file?**
When I ran `terraform init`, Terraform downloaded the provider and created a lock file. Think of this as a "receipt." It locks in the exact version and hash of the provider I downloaded so that if my teammate clones this repo tomorrow, they get the exact same version. It prevents the "it works on my machine" problem!

---

## Task 2 & 4: Building the VPC, Security Group, and EC2 Instance

I wrote out my `main.tf` file to build a custom networking environment. Instead of using default AWS resources, I built:
1. A **VPC** (`10.0.0.0/16`)
2. A **Public Subnet** (`10.0.1.0/24`)
3. An **Internet Gateway** so my network can reach the web.
4. A **Route Table** and **Association** to route `0.0.0.0/0` (internet traffic) to the Gateway.
5. A **Security Group** allowing Port 22 (SSH) and Port 80 (HTTP) from `0.0.0.0/0`.
6. An **EC2 Instance** (Amazon Linux 2) sitting right inside that subnet.

After fixing a quick typo in my Security Group (making sure my `cidr_ipv4` allowed outside traffic instead of just VPC traffic), I ran `terraform apply`. My instance spun up, got a public IP, and was completely reachable!

---

## Task 3: Understanding Implicit Dependencies

When I looked at my code, I didn't explicitly tell Terraform to build the VPC first. So how did it know?

**How Terraform figures out the order:**
Terraform automatically builds a Dependency Graph. Because my Subnet code contained `vpc_id = aws_vpc.vpc.id`, Terraform realized, *"Hey, I can't build the subnet until I know the VPC's ID. I better build the VPC first."* This is called an **Implicit Dependency**.

**What if I tried to force the subnet first?**
If Terraform tried to create the subnet before the VPC existed, the AWS API would immediately reject the request because the `vpc_id` would be invalid or null, and Terraform would crash with an error.

**Implicit Dependencies in my config:**
* **Subnet** depends on the **VPC**.
* **Internet Gateway** depends on the **VPC**.
* **Route Table** depends on the **VPC** and **Internet Gateway**.
* **Route Table Association** depends on the **Subnet** and the **Route Table**.
* **Security Group** depends on the **VPC**.
* **EC2 Instance** depends on the **Subnet** and the **Security Group**.

---

## Task 5: Explicit Dependencies (`depends_on`)

Sometimes Terraform's brain needs a little help. I added an S3 bucket for application logs. S3 buckets are global and don't require a VPC ID, so Terraform would normally just create it immediately. 

However, I wanted to ensure the EC2 server was fully created *before* the S3 bucket. Since there was no implicit link between them, I used an explicit dependency:

```hcl
resource "aws_s3_bucket" "app_logs" {
  bucket     = "terraweek-app-logs-unique-id-123"
  depends_on = [aws_instance.web_server]
}

```
### When would you use `depends_on` in the real world?

* **Application-to-Database:** You have an EC2 instance that runs a startup script expecting a database to be fully available. Even if the EC2 doesn't reference the DB ID in Terraform, you use `depends_on` so the server waits for the DB to finish provisioning.
* **IAM Role Propagation:** Sometimes IAM roles take a few seconds to propagate through AWS. You might make a resource depend on a specific IAM attachment finishing before trying to assume that role.

*(Side note: I ran `terraform graph | dot -Tpng > graph.png` to visualize this, and the resulting dependency tree was awesome to look at!)*

---

## Task 6: Lifecycle Rules and Destroying

Finally, I played around with lifecycle blocks. I added this to my EC2 instance:

```hcl
lifecycle {
  create_before_destroy = true
}
```
When I changed the AMI ID and ran terraform plan, Terraform didn't just kill my server. Instead, it planned to build the new server first, and only destroy the old one once the new one was ready. This is amazing for zero-downtime updates!

### The 3 main lifecycle arguments:
create_before_destroy: Perfect for web servers or load balancers where you want the new version up and running before terminating the old one to avoid dropping traffic.

prevent_destroy: The ultimate safety net. Use this on critical databases or state files so no one can accidentally delete them with a careless terraform destroy.

ignore_changes: Great if a resource is managed partly by Terraform and partly by something else (like an auto-scaling group that changes its own desired capacity). Terraform will ignore those specific changes instead of trying to revert them.

To wrap up the day, I ran terraform destroy. I watched Terraform tear everything down in exact reverse-dependency order. A perfectly clean slate.
