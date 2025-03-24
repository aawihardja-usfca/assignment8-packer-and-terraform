# AWS AMI & Infrastructure Provisioning with Packer and Terraform

This repository contains scripts to create a custom AWS AMI with Packer and to provision AWS infrastructure using Terraform. The custom AMI is based on Amazon Linux, pre-installed with Docker, and preconfigured with your SSH public key for secure access. The Terraform configuration sets up a complete AWS environment including VPC, public and private subnets, a bastion host, and six EC2 instances in the private subnet using your custom AMI.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Setup](#setup)
  - [AWS Credentials](#aws-credentials)
  - [SSH Key Pair](#ssh-key-pair)
- [Packer AMI Creation](#packer-ami-creation)
  - [Initialize and Validate](#initialize-and-validate)
  - [Build the AMI](#build-the-ami)
- [Terraform Infrastructure Provisioning](#terraform-infrastructure-provisioning)
  - [IP Setup for Bastion Host Access](#ip-setup-for-bastion-host-access)
  - [Initialize, Validate, and Apply](#initialize-validate-and-apply)
- [Testing and Verification](#testing-and-verification)
  - [SSH Access](#ssh-access)
- [Troubleshooting](#troubleshooting)
- [Screenshot](#screenshot)

## Prerequisites
* #### Packer
    Install using the precompiled binaries and add to your `PATH`. For detailed instructions, please refer to the [official Packer documentation](https://developer.hashicorp.com/packer/tutorials/aws-get-started/get-started-install-cli)

* #### Terraform
    Install using the precompiled binaries and add to your `PATH`. Detailed instructions are available in the [official Terraform documentation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

* #### AWS account & credentials
    Ensure you have valid AWS credentials set up either via environment variables or an AWS credentials file.

* #### SSH Key Pair
    You need an SSH key pair (named `my-aws-key`) that Packer will use to embed your public key in the AMI for SSH access.

## Setup

### AWS credentials
You can set your AWS credentials by exporting them as environment variables:<br>
```shell
export AWS_ACCESS_KEY_ID="<YOUR_AWS_ACCESS_KEY_ID>"
export AWS_SECRET_ACCESS_KEY="<YOUR_AWS_SECRET_ACCESS_KEY"
```

Alternatively, create a credentials file at:
- Linux/OS X: `$HOME/.aws/credentials`
- Windows: `%USERPROFILE%\.aws\credentials`

<i>Example credentials file content:</i>
```ini
[default]
aws_access_key_id=<your access key id>
aws_secret_access_key=<your secret access key>
aws_session_token=<your session token>
```
Packer will use the default profile.

### SSH key pair
Generate a key pair:
```bash
ssh-keygen -t rsa -b 4096 -f my-aws-key
```
Leave the passphrase empty. This command creates both <code>my-aws-key</code> and <code>my-aws-key.pub</code> in the current directory. Packer will copy <code>my-aws-key.pub</code> to add it to the list of authorized keys in the AMI.

## Packer AMI Creation

### Initialize and validate

1. #### Initialize the Packer configuration:
    ```bash
    packer init .
    ```

2. #### Validate the Packer file:
    ```bash
    packer validate .
    ```

### Build the AMI
Build your AMI using the following command:
```bash
packer build aws-amazonlinux.pkr.hcl
```

After a successful build, you should see output indicating the new AMI ID (e.g., <code>ami-0fb61569f4da07616</code>). You can verify this AMI in your AWS Console under <b>EC2 > Images > AMI</b>.

<i>Example output snippet:</i>
```yaml
==> learn-packer.amazon-ebs.amazon-linux: Creating AMI packer-ami from instance i-073fd58a56d483b1d
    learn-packer.amazon-ebs.amazon-linux: AMI: ami-0fb61569f4da07616
==> Builds finished.
```

## Terraform Infrastructure Provisioning
The Terraform scripts provision AWS resources including a VPC (with public and private subnets), a bastion host in the public subnet, and six EC2 instances in the private subnet using your custom AMI.

### IP setup for Bastion Host access
Before provisioning, set your IP so that you can securely SSH into the bastion host. Make the <code>get_my_ip.sh</code> script executable:
```bash
chmod +x get_my_ip.sh
```

### Initialize, validate, and apply

1. #### Initialize the Terraform configuration:
    ```bash
    terraform init
    ```

2. #### Validate the Terraform configuration

    ```bash
    terraform validate
    ```
    Look for a success message: <code><font color="green">Success!</font> The configuration is valid.</code>

3. #### Apply Terraform

    ```bash
    terraform apply
    ```
    Review the plan, then type yes when prompted. The apply process will provision the resources and output the following:

    - <b>bastion_public_ip</b>: The public IP of the bastion host.

    - <b>ec2_ips</b>: A list of private IP addresses for the six EC2 instances.

    <i>Example output</i>
    ```bash
    Outputs:

    bastion_public_ip = "3.216.112.41"
    ec2_ips = [
    "10.0.1.196",
    "10.0.1.85",
    "10.0.1.163",
    "10.0.1.140",
    "10.0.1.61",
    "10.0.1.171",
    ]
    ```

## Testing and Verification
### SSH access
1. #### Add your private key to the SSH Agent:

    ```bash
    ssh-add my-aws-key
    ```

2. #### SSH into the Bastion host:<br>
    Replace <code><bastion_public_ip></code> with the output from Terraform:

    ```bash
    ssh -A -i my-aws-key ec2-user@<bastion_public_ip>
    ```
    Accept the host key when prompted.

3. #### Verify Docker Installation on the Bastion Host:

    ```bash
    docker --version
    ```
    Expected output (e.g., <code>Docker version 25.0.8, build 0bab007</code>).

4. #### SSH from the Bastion Host to a Private EC2 Instance:
    Replace <code><ec2_ip></code> with one of the private IP addresses:
    ```bash
    ssh ec2-user@<ec2_ip>
    ```

5. #### Verify Docker Installation on the Private Instance:

    ```bash
    docker --version
    ```

## Troubleshooting
- #### Missing SSH Key Error:<br>
    If Packer cannot find <code>my-aws-key.pub</code>, ensure you have created the key pair as described in the SSH Key Pair section.

- #### Terraform Apply Failures:<br>
    Verify that your AWS credentials are correctly set up and that your VPC/subnet configurations meet AWS requirements.

## Screenshot
