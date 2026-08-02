# ---------------------------------------------------------
# Data Source: Automatically grab the latest Ubuntu 22.04 AMI
# ---------------------------------------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# ---------------------------------------------------------
# 1. Network Module (VPC)
# ---------------------------------------------------------
module "vpc" {
  source             = "./modules/vpc"

  # Pass variables defined in your root variables.tf
  cidr               = var.vpc_cidr
  public_subnet_cidr = var.subnet_cidr
  
  # Pass workspace-aware locals
  environment        = local.environment
  project_name       = var.project_name
}

# ---------------------------------------------------------
# 2. Security Group Module
# ---------------------------------------------------------
module "security_group" {
  source        = "./modules/security-group"
  
  # Implicit dependency: Fetch the VPC ID from the VPC module output
  vpc_id        = module.vpc.vpc_id 
  
  ingress_ports = var.ingress_ports
  
  environment   = local.environment
  project_name  = var.project_name
}

# ---------------------------------------------------------
# 3. Compute Module (EC2)
# ---------------------------------------------------------
module "ec2_instance" {
  source             = "./modules/ec2-instance"
  
  ami_id             = data.aws_ami.ubuntu.id
  instance_type      = var.instance_type
  
  # Implicit dependencies: Connect to the Subnet and Security Group
  subnet_id          = module.vpc.subnet_id
  security_group_ids = [module.security_group.sg_id]
  
  environment        = local.environment
  project_name       = var.project_name
}