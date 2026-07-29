locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


# --- Task 2: VPC from Scratch ---
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_prefix}-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "TerraWeek-IGW"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

tags = merge(local.common_tags, {
  Name = "${local.name_prefix}-Rout-Table"
})
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# --- Task 4: Security Group & EC2 Instance ---
resource "aws_security_group" "web_sg" {
  name        = "TerraWeek-SG"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

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

# Fetching latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "main" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type = var.environment == "prod" ? "t3.small" : "t2.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "${local.name_prefix}-server"
  }

  # Task 6: Lifecycle Rule
  lifecycle {
    create_before_destroy = true
  }
}

# --- Task 5: Explicit Dependencies ---
resource "aws_s3_bucket" "app_logs" {
  bucket = "terraweek-logs-bucket-${random_id.bucket_id.hex}" # S3 bucket names must be globally unique
  
  # Explicitly tell Terraform to create the EC2 instance BEFORE the S3 bucket
  depends_on = [aws_instance.main]
}

resource "random_id" "bucket_id" {
  byte_length = 4
}