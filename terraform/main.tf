terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "foodops_key" {
  key_name   = "foodops-key"
  public_key = file("~/.ssh/foodops-key.pub")
}


# Get the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {

  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}


# Security Group
resource "aws_security_group" "foodops_sg" {

  name        = "foodops-security-group"
  description = "Security group for FoodOps application"


  # SSH
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["110.226.114.171/32"]
  }

  # Flask application
  ingress {
    description = "Flask application"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    description = "HTTP access for FoodOps"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# EC2 Instance
resource "aws_instance" "foodops" {

  ami = data.aws_ami.amazon_linux.id

  instance_type = "t3.micro"

  security_groups = [aws_security_group.foodops_sg.name]

  user_data = file("${path.module}/user_data.sh")

  key_name = aws_key_pair.foodops_key.key_name
  tags = {
    Name = "FoodOps-Server"
  }

  root_block_device {
    delete_on_termination = true
  }
}