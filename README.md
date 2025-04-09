# Vault Setup
=========
This is a simple setup using Terraform and Ansible to setup Vault.

> Note: This is a work in progress so double-check scripts and plans.

Prerequisites
-------------
1. Ensure you have an SSH Key in AWS

Usage
-----
1. Login to AWS at your CLI
2. Change to the "terraform" directory
3. Run `terraform init` (first time only)
4. Update the 'demo.tfvars' with your details (or make a new copy)
5. Run `terraform apply --var "my_ip_cidr=$(curl ifconfig.me)/32" -var-file=demo.tfvars`
6. If all looks good enter `yes` to apply

# Install Vault

- ssh ec2-uers@<server>
- sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
- sudo yum -y install vault

# Starting Vault
sudo vault server -config=/etc/vault.d/vault.hcl

# Access Vault 
https://lab-vault.<dns entry>:8200/

# Install HVAC and Ansible
- python3 -m venv .venv
- source .venv/bin/activate
- pip install ansible hvac