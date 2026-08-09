
resource "aws_instance" "example" {
  count         = 3
  ami           = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type = "t3.micro"
  vpc_security_group_ids = [ aws_security_group.web_sg.id ]
  key_name = "terra-ansible"


  tags = {
    Name = "server-${count.index}"
  }
}


resource "aws_security_group" "web_sg" {
  name        = "TerraWeek-SG"
  description = "Allow SSH and HTTP inbound traffic"
 

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "TerraWeek-SG"
  }
}

# 4. Output the Public IPs of the Instances
output "instance_public_ips" {
  description = "Public IP addresses of the created EC2 instances"
  value       = aws_instance.example[*].public_ip
}