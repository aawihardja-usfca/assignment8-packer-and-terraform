packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

### Amazon Linux AMI
source "amazon-ebs" "amazon-linux" {
  ami_name      = "amazon-linux-ami"
  instance_type = "t2.micro"
  region        = "us-east-1"
  profile       = "default"
  source_ami_filter {
    filters = {
      name                = "al2023-ami-2023*"
      architecture        = "x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  ssh_username = "ec2-user"
  tags = {
    OS = "Amazon Linux"
  }
}

build {
  name = "learn-packer-amazon-linux"
  sources = [
    "source.amazon-ebs.amazon-linux"
  ]

  # Copy your SSH public key to the instance
  provisioner "file" {
    source      = "./my-aws-key.pub"
    destination = "/home/ec2-user/.ssh/authorized_keys"
  }

  # Ensure proper ownership and permissions on the authorized_keys file
  provisioner "shell" {
    inline = [
      "sudo chown ec2-user:ec2-user /home/ec2-user/.ssh/authorized_keys",
      "sudo chmod 600 /home/ec2-user/.ssh/authorized_keys"
    ]
  }

  provisioner "shell" {
    script = "./scripts/create_ami_rpm.sh"
  }
}

### Ubuntu AMI
source "amazon-ebs" "ubuntu" {
  ami_name      = "ubuntu-ami"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  tags = {
    OS = "Ubuntu"
  }
}

build {
  name = "learn-packer-ubuntu"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  # Copy your SSH public key to the instance
  provisioner "file" {
    source      = "./my-aws-key.pub"
    destination = "/home/ubuntu/.ssh/authorized_keys"
  }

  # Ensure proper ownership and permissions on the authorized_keys file
  provisioner "shell" {
    inline = [
      "sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys",
      "sudo chmod 600 /home/ubuntu/.ssh/authorized_keys"
    ]
  }

  provisioner "shell" {
    script = "./scripts/create_ami_deb.sh"
  }
}