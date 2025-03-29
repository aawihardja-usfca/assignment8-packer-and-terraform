provider "aws" {
  region = var.aws_region
}

# Get the Amazon Linux AMI
data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["*ami*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "tag:OS"
    values = ["Amazon Linux"]
  }
}

# Get the Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["*ami*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "tag:OS"
    values = ["Ubuntu"]
  }
}

# Run the script get_my_ip.sh
data "external" "my_ip" {
  program = ["bash", "${path.module}/scripts/get_my_ip.sh"]
}


# Create an EIP for the NAT
resource "aws_eip" "nat" {
  count  = 1
  domain = "vpc"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs = var.aws_azs

  private_subnets = var.aws_private_subnet_cidr
  public_subnets  = var.aws_public_subnet_cidr

  # Single NAT for all AZ
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  reuse_nat_ips       = true             # <= Skip creation of EIPs for the NAT Gateways
  external_nat_ip_ids = aws_eip.nat.*.id # <= IPs specified here as input to the module

  enable_dns_hostnames = true
}