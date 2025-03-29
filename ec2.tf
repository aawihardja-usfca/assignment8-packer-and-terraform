# Provision EC2s using Amazon Linux AMI
resource "aws_instance" "ec2-amazon-linux" {
  count                  = 3
  ami                    = data.aws_ami.amazon-linux.id
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "EC2 Amazon Linux ${count.index + 1}"
    OS   = "Amazon Linux"
  }
}

# Provision EC2s using Ubuntu AMI
resource "aws_instance" "ec2-ubuntu" {
  count                  = 3
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.private_subnets[1]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "EC2 Ubuntu ${count.index + 1}"
    OS   = "ubuntu"
  }
}

# Provision EC2 for Ansible controller
resource "aws_instance" "ansible-controller" {
  ami                    = data.aws_ami.amazon-linux.id
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.controller_sg.id]

  associate_public_ip_address = true

  tags = {
    Name = "Ansible Controller"
    OS   = "amazon"
  }
}