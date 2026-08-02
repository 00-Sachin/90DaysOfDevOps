resource "aws_instance" "main" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  
  # Note: EC2 expects a list of security group IDs
  vpc_security_group_ids = var.security_group_ids

  tags = {
    Name        = "${var.project_name}-server-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}