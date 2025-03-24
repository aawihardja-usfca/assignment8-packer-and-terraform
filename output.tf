output "bastion_public_ip" {
  description = "The public IP of the bastion host"
  value       = aws_eip.bastion_ip.public_ip
}

output "ec2_ips" {
  description = "Private IPs of the 6 EC2 instances"
  value       = aws_instance.ec2[*].private_ip
}