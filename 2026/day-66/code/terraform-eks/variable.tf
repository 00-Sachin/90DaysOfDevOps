variable "region" {
    description = "The AWS region to create resources in"
    type       = string
    default    = "us-west-1" 
}
variable "cluster_name" {
    description = "The cluster name used to "
    type = string
    default = "terraweek-eks"
}
variable "cluster_version" {
    description = "Which version of cluster is to be used "
    type = string
    default = "1.31"
  
}

variable "node_instance_type" {
    description = "what type of instance provided to nodes"
    type = string
    default = "m7i-flex.large"
    
  
}
variable "node_desired_count" {
    description = "The total number of nodes required"
    type = number
    default = 2
  
}

variable "vpc_cidr" {
    description = "THe total number of ip's  allows in vpc"
    type = string
    default = "10.0.0.0/16"
  
}
