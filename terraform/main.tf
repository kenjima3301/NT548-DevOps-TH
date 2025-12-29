provider "aws" {
  region = var.aws_region
}

module "networking" {
  source              = "./modules/networking"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  az                  = "${var.aws_region}a"
}

module "security" {
  source = "./modules/security"
  vpc_id = module.networking.vpc_id
  my_ip  = var.my_personal_ip
}

module "compute" {
  source            = "./modules/compute"
  ami_id            = "ami-00d8fc944fb171e29" 
  key_name          = var.key_pair_name
  public_subnet_id  = module.networking.public_subnet_id
  private_subnet_id = module.networking.private_subnet_id
  public_sg_id      = module.security.public_sg_id
  private_sg_id     = module.security.private_sg_id
}

output "connect_command" {
  value = "ssh -i ${var.key_pair_name}.pem ubuntu@${module.compute.public_ip}"
}
output "private_ip_address" {
  value = module.compute.private_ip
}