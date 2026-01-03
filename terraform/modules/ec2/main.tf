resource "aws_instance" "public_ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = {
    Name = "NT548-Public-EC2"
  }
}

resource "aws_instance" "private_ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "NT548-Private-EC2"
  }
}

# Security group for Public EC2 & Private EC2
resource "aws_security_group" "public_sg" {
  name        = "public-ec2-sg"
  description = "Allow SSH from specific IP"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from My IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Public-EC2-SG"
  }
}

resource "aws_security_group" "private_sg" {
  name        = "private-ec2-sg"
  description = "Allow SSH only from Public EC2"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from Public EC2"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Private-EC2-SG"
  }
}
