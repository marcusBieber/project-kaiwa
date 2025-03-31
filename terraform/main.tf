provider "aws" {
  region = "eu-central-1"
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "./ansible-key.pem"
  file_permission = "0600"
}

resource "aws_key_pair" "generated_key" {
  key_name   = "web-instances-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and 8080 access"

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

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP access"

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
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server*"]
  }
}

resource "aws_instance" "jenkins" {
  count           = var.jenkins_instance_count
  ami             = data.aws_ami.ubuntu.id # "ami-07eef52105e8a2059" # Ubuntu
  instance_type   = "t3.large"
  key_name        = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.jenkins_sg.name]

  tags = {
    Name = "jenkins-instance_${count.index}"
  }
}

resource "aws_instance" "web" {
  count           = var.web_instance_count
  ami             = data.aws_ami.ubuntu.id # "ami-07eef52105e8a2059" # Ubuntu
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = "web-instance-${count.index}"
  }
}
