resource "aws_instance" "public_ec2" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.public_sg_id]
  key_name               = var.key_name

  tags = { Name = "NT548-Public-EC2" }
}

resource "aws_instance" "private_ec2" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.private_sg_id]
  key_name               = var.key_name

  tags = { Name = "NT548-Private-EC2" }
}