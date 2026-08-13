
resource "aws_instance" "server" {
  for_each = var.servers                                    # every server get its unique name as mentioned in the variable 
  ami           = var.ami                                   # UBUNTU
  instance_type = var.instance_type                         # t3.micro
  vpc_security_group_ids = [ aws_security_group.web_sg.id ]
  key_name = var.key_name                                    # key_pair_name

  tags = {
    Name = each.key
    Role = each.value.role
  }
}


resource "aws_security_group" "web_sg" {
  name        = "Ansible-capstone-SG"
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
    Name = "Ansible-capstone-sg"
  }
}



resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible-docker-project/inventory.ini"

  content = templatefile("${path.module}/inventory.ini.tftpl", {
    web_ip = aws_instance.server["web"].public_ip
    app_ip = aws_instance.server["app"].public_ip
    db_ip  = aws_instance.server["db"].public_ip
  })
}