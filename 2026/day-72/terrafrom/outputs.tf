output "instance_public_ips" {
  description = "Public IP addresses of the EC2 instances"

  value = {
    for name, instance in aws_instance.server :
    name => instance.public_ip
  }
}