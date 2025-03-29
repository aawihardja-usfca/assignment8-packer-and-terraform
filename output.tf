output "controller_public_ip" {
  description = "The public IP of the Ansible controller"
  value       = aws_instance.ansible-controller.public_ip
}

output "amazon_linux_ips" {
  description = "Private IPs of the Amazon Linux EC2s"
  value       = aws_instance.ec2-amazon-linux[*].private_ip
}

output "ubuntu_ips" {
  description = "Private IPs of the Ubuntu EC2s"
  value       = aws_instance.ec2-ubuntu[*].private_ip
}