resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon-linux.id
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  associate_public_ip_address = true

  tags = {
    Name = "Bastion Host"
  }
}

resource "aws_eip" "bastion_ip" {
  instance = aws_instance.bastion.id
}