packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "amazon-linux" {
  ami_name      = "packer-ami"
  instance_type = "t2.micro"
  region        = "us-east-1"
  profile       = "default"
  source_ami_filter {
    filters = {
      name                = "al2023-ami-2023*"
      "architecture"      = "x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  ssh_username = "ec2-user"
}

build {
  name = "learn-packer"
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
    script = "create_ami.sh"
  }
}
