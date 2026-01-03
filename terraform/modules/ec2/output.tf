output "public_ip" {
  description = "Public IP of Public EC2"
  value       = aws_instance.public_ec2.public_ip
}

output "private_ip" {
  description = "Private IP of Private EC2"
  value       = aws_instance.private_ec2.private_ip
}
