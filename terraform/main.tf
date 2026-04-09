provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "devops_key" {
  key_name   = "devops-local-key"
  public_key = file("${path.module}/devops-local-key.pub")
}

resource "aws_security_group" "devops_sg" {
  name        = "devops-mini-project-sg"
  description = "Allow SSH, HTTP, and app port"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App Port"
    from_port   = 8080
    to_port     = 8080
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
    Name = "devops-mini-project-sg"
  }
}

resource "aws_instance" "devops_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.devops_key.key_name
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  user_data = <<-EOF
            #!/bin/bash
            apt update -y
            apt install -y docker.io
            systemctl enable docker
            systemctl start docker
            usermod -aG docker ubuntu
            EOF

  tags = {
    Name = "devops-mini-project-server"
  }
}