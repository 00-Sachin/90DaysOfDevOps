resource "aws_security_group" "main" {
  name        = "${var.project_name}-sg-${var.environment}"
  description = "Managed by Terraform - Security Group for ${var.project_name}"
  vpc_id      = var.vpc_id

  # DYNAMIC BLOCK: Loops through the ingress_ports list to create multiple rules
  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] # Caution: Opens to the world. In prod, restrict this!
    }
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols (TCP, UDP, ICMP, etc.)
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-sg-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}