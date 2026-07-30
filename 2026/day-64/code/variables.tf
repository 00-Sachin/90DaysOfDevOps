  variable "region" {
    type        = string
    description = "The region of the ec2"
    default     = "us-west-1"
  }
  variable "vpc_cidr" {
    type        = string
    description = "This tell tottal number of ip in the vpc"
    default     = "10.0.0.0/16"
  }
  variable "subnet_cidr" {
    type        = string
    description = "This tell tottal number of ip in the subnets"
    default     = "10.0.1.0/24"
  }

  variable "instance_type" {
    type        = string
    description = "This tell which instance u are using"
    default     = "t3.micro"
  }

  variable "project_name" {
    type        = string
    description = "Enter the name of the project"
  }
  variable "environment" {
    type        = string
    default = "dev"
  }
  variable "allowed_ports" {
    type = list(number)
    default = [ 20, 80, 443 ]
  }
  variable "extra_tags" {
    type = map(string)

    default = {}
    
  }
