variable "region" {
type = string
default = "us-west-1"
  
}

variable "ami" {
type =   string
default = "ami-0fb110df4c5094d21 (64-bit (x86)) / ami-05ec7cd51fae886fa (64-bit (Arm))"
}

variable "key_name" {
    type = string
    default = "terra-ansible"
}

variable "servers" {
  default = {
    web = {
      role = "web"
    }

    app = {
      role = "app"
    }

    db = {
      role = "db"
    }
  }
}

variable "instance_type" {
    type = string
    default = "t3.micro"
  
}