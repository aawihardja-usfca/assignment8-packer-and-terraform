#!/bin/bash

PUBLIC_IP="your.ec2.public.ip"
KEY="my-aws-key.pem"  

# SCP to copy ./ansible directory into the Ansible controller machine:
scp -r -i "$KEY" ./ansible ec2-user@$"PUBLIC_IP":~

# SSH into the remote EC2 instance and run installation commands
ssh -i "$KEY" ec2-user@"$PUBLIC_IP" <<'EOF'
  # Install python3-pip
  sudo dnf install -y python3-pip

  # Install Ansible using pip
  python3 -m pip install --user ansible

  # Install required Python packages
  pip install -r ~/ansible/requirements.txt
EOF