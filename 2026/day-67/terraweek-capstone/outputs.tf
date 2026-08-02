output "current_workspace" {
  description = "The current active Terraform workspace"
  value       = terraform.workspace
}

output "vpc_id" {
  description = "The ID of the VPC for this environment"
  value       = module.vpc.vpc_id
}

output "server_public_ip" {
  description = "The Public IP address of the EC2 instance"
  value       = module.ec2_instance.public_ip
}