output "instance_id" {
  description = "The ID of the created EC2 instance"
  value       = aws_instance.main.id
}

output "public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.main.public_ip
}