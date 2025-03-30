#!/bin/bash

MY_IP_JSON=$(./scripts/get_my_ip.sh)
MY_IP=$(echo "$MY_IP_JSON" | jq -r '.ip')
MY_IP=${MY_IP%/*}

CONTROLLER_IP="34.232.50.23"
KEY="my-aws-key"

# Copy ansible directory to controller machine:
scp -i "$KEY" -o StrictHostKeyChecking=no -r ./ansible ec2-user@"$CONTROLLER_IP":~

# Create .aws directory on the controller machine
ssh -i "$KEY" -o StrictHostKeyChecking=no ec2-user@"$CONTROLLER_IP" "mkdir -p ~/.aws"

# Copy credential file to controller machine:
scp -i "$KEY" -o StrictHostKeyChecking=no credentials ec2-user@"$CONTROLLER_IP":~/.aws/credentials

# SSH into the remote EC2 instance and run installation commands
ssh -i "$KEY" -o StrictHostKeyChecking=no ec2-user@"$CONTROLLER_IP" <<'EOF'
  # Install python3-pip
  sudo dnf install -y python3-pip

  # Install Ansible using pip
  python3 -m pip install --user ansible

  # Install required Python packages
  pip install -r ~/ansible/requirements.txt

EOF