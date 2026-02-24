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
  ami           = "ami-019715e0d74f695be" # Ubuntu 22.04 LTS AMI (Verify for your region)
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.project_sg.id]
  key_name      = "RealDevopskey" # Change this to your existing AWS Key Pair name

  tags = {
    Name = "DevOps-Project-Instance"
  }
}

output "instance_public_ip" {
  value = aws_instance.app_server.public_ip
}
