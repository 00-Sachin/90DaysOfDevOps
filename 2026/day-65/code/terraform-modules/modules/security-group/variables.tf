variable "vpc_id" {
  description = "The VPC ID where the security group will be created"
  type        = string
}

variable "sg_name" {
  description = "The name of the security group"
  type        = string
}

variable "ingress_ports" {
  description = "List of ingress ports to open"
  type        = list(number)
  default     = [22, 80]
}

variable "tags" {
  description = "Tags for the security group"
  type        = map(string)
  default     = {}
}