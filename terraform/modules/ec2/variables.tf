variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ami_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  description = "Public Subnet ID to launch the EC2 instance in"
  type        = string
}

variable "private_subnet_id" {
  description = "Private Subnet ID to launch the EC2 instance in"
  type        = string
}

variable "key_name" {
  description = "Name of key pair for EC2"
  type        = string
  default     = "null"
}

variable "my_ip" {
  description = "My IP address"
  type        = string
}
