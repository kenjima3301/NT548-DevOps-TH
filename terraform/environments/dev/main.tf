provider "aws" {
  region = "ap-southeast-1"
}

module "network" {
  source              = "../../modules/network"
  environment         = "dev"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

resource "aws_key_pair" "my_key" {
  key_name   = "dev-key"
  public_key = file("../../modules/my-aws-key.pub")
}

module "ec2" {
  source            = "../../modules/ec2"
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  vpc_id            = module.network.vpc_id
  public_subnet_id  = module.network.public_subnet_ids
  private_subnet_id = module.network.private_subnet_ids

  key_name = aws_key_pair.my_key.key_name
  my_ip    = var.my_ip
}
