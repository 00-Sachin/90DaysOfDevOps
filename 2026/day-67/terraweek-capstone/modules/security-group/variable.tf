variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string
}

variable "ingress_ports" {
  description = "A list of ports to open for inbound traffic"
  type        = list(number)
}

variable "environment" {
  description = "The environment (e.g., dev, prod)"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}