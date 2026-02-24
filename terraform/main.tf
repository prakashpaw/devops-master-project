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

  # Adding -y and ensuring the shell is specified correctly
  user_data = <<-EOF
              #!/bin/bash
              set -e
              apt-get update -y
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              docker run -d -p 8080:8080 pawarpr/devops-java-app:latest
              EOF

  # This forces the instance to recreate if the user_data changes
  user_data_replace_on_change = true

  tags = {
    Name = "DevOps-Project-Instance"
  }
}
