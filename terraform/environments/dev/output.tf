output "ssh_command_public" {
  description = "SSH command to access Public EC2"
  value       = "ssh -i my-aws-key ubuntu@${module.ec2.public_ip}"
}

output "ssh_command_private_jump" {
  description = "SSH command to access Private EC2 from Public EC2"
  value       = "ssh -J ubuntu@${module.ec2.public_ip} -i my-aws-key ubuntu@${module.ec2.private_ip}"
}

output "raw_ips" {
  value = {
    public_ip  = module.ec2.public_ip
    private_ip = module.ec2.private_ip
  }
}
