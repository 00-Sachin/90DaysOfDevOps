# Day 63: Variables, Outputs, Data Sources, and Expressions

Making Terraform dynamic is what changes it from a one-time script into a reusable tool. Here is the documentation of what I learned and built today.

---

## 1. My Variables Configuration (`variables.tf`)

Here is how I extracted all the hardcoded values from my previous code into dynamic input variables. It includes different types of variables like strings, lists, and maps.

```hcl
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "project_name" {
  type        = string
  description = "The name of the project. This has no default, so Terraform will ask for it."
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "allowed_ports" {
  type    = list(number)
  default = [22, 80, 443]
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}
```
## 2. Environment Variable Files (.tfvars)

By keeping .tfvars files, I can use the exact same infrastructure code for different environments just by swapping the file.    

### Default (terraform.tfvars):

``` 
project_name  = "terraweek"
environment   = "dev"
instance_type = "t2.micro"

```
### Production (prod.tfvars):

```
project_name  = "terraweek"
environment   = "prod"
instance_type = "t3.small"
vpc_cidr      = "10.1.0.0/16"
subnet_cidr   = "10.1.1.0/24"

```
## 3. The Five Main Variable Types in Terraform

Terraform variables act like containers for our data. Here are the five basic types:

* **String:** Just regular text (e.g., `"t2.micro"` or `"dev"`).
* **Number:** A solid number without quotes (e.g., `80` or `443`).
* **Bool:** A simple `true` or `false` statement (e.g., `true`).
* **List:** An ordered collection of items of the same type (e.g., `[22, 80, 443]`).
* **Map:** A collection of key-value pairs, great for tagging (e.g., `{ Environment = "dev", Team = "DevOps" }`).

---

## 4. Variable Precedence (Who wins?)

If I set the exact same variable in five different places, Terraform has a strict "chain of command" to decide which value to actually use.

Here is the priority order, from **lowest priority to highest priority**:

1. **Environment Variables:** Things set in my terminal like `export TF_VAR_environment="staging"`.
2. **`terraform.tfvars`:** The default file Terraform automatically looks for.
3. **`*.auto.tfvars` files:** Any file ending in this extension gets loaded automatically and overrides the basic `terraform.tfvars`.
4. **`-var-file` flag:** Telling Terraform exactly which file to use in the command line (e.g., `terraform apply -var-file="prod.tfvars"`).
5. **`-var` flag:** Passing a specific value right in the command line (e.g., `terraform apply -var="instance_type=t2.nano"`). This overrides absolutely everything else.

---

## 5. Terminology: Variables, Locals, Outputs, Data Sources, and Resources

It's easy to get these confused, so here is the simple difference:

* **Variable:** An input. It's how I pass information into my Terraform code from the outside (like asking a user for a project name).
* **Local:** An internal shortcut. If I have a complex calculation or a long name (like `"terraweek-dev-vpc"`), I define it once as a local and reuse it inside the code so I don't have to type it out every time.
* **Output:** A result. It's the information Terraform prints out on my screen after it finishes building things (like giving me the new EC2 Public IP so I can log in).
* **Resource:** A creator. This tells Terraform to actually go out and build or manage something in AWS (like creating a brand new VPC).
* **Data Source:** A reader. This just queries AWS to fetch existing information (like looking up the ID of the latest Amazon Linux 2 AMI) without creating or changing anything.

---

## 6. Five Really Useful Terraform Functions

Functions let us manipulate data easily. Here are five great ones:

* **`upper()`:** Converts a string to all uppercase letters. Great for making sure naming conventions are consistent.
* **`join()`:** Glues a list of strings together using a separator (like a hyphen). Example: `join("-", ["my", "app"])` becomes `"my-app"`.
* **`length()`:** Counts how many items are in a list or map. This is incredibly useful if I want to create exactly as many subnets as there are items in my CIDR block list.
* **`merge()`:** Combines two or more maps together. I use this to take my standard `common_tags` and merge them with specific tags for an individual resource.
* **`cidrsubnet()`:** Does network math for me! Instead of hardcoding subnet IPs, it calculates the correct subnet CIDR blocks dynamically based on the main VPC network.