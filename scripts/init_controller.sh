#!/bin/bash

CONTROLLER_IP="18.215.63.83"
KEY="my-aws-key"

# Copy ansible directory to controller machine:
scp -i "$KEY" -o StrictHostKeyChecking=no -r ./ansible ec2-user@"$CONTROLLER_IP":~

# Copy the public + private SSH key to connect with the managed EC2s
scp -i "$KEY" -o StrictHostKeyChecking=no ./"$KEY" ./"$KEY".pub ec2-user@"$CONTROLLER_IP":~/.ssh

# SSH into the Controller and update the private key's permission
ssh -i "$KEY" -o StrictHostKeyChecking=no ec2-user@"$CONTROLLER_IP" <<'EOF'
  chmod 600 ~/.ssh/my-aws-key
EOF

# Create .aws directory on the controller machine
ssh -i "$KEY" -o StrictHostKeyChecking=no ec2-user@"$CONTROLLER_IP" "mkdir -p ~/.aws"

# Copy AWS credential file to controller machine:
scp -i "$KEY" -o StrictHostKeyChecking=no credentials ec2-user@"$CONTROLLER_IP":~/.aws/credentials

# SSH into the Controller and install packages
ssh -i "$KEY" -o StrictHostKeyChecking=no ec2-user@"$CONTROLLER_IP" <<'EOF'
  # Install python3-pip
  sudo dnf install -y python3-pip

  # Install Ansible using pip
  python3 -m pip install --user ansible

  # Install required Python packages
  pip install -r ~/ansible/requirements.txt

EOF