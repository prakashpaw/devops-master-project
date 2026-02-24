# 1. Create a Security Group for the Application
resource "aws_security_group" "project_sg" {
  name        = "devops-project-sg"
  description = "Allow SSH and App traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
}

# 2. Create the EC2 Instance
resource "aws_instance" "app_server" {
  ami           = "ami-019715e0d74f695be" 
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.project_sg.id]
  key_name      = "RealDevopskey"

  # This script runs automatically when the instance starts
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              # Run your specific docker image
              sudo docker run -d -p 8080:8080 pawarpr/devops-java-app:latest
              EOF

  tags = {
    Name = "DevOps-Project-Instance"
  }
}
