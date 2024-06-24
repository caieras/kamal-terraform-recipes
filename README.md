# Kamal Terraform AWS Recipe

This Terraform configuration sets up the basic infrastructure for a Ruby on Rails application running on AWS, providing also a basic configuration to the server using cloud-init.

Use this as a foundation to jumpstart your **development/staging** environment and iterate as your project evolves. While this configuration provides essential building blocks, it's not production-ready and should be customized to meet your specific application needs, security requirements, and budget constraints.

#### ROADMAP:

| Provider | Status | Resources | Link
|----------|----------|----------| --------
| AWS      | ✅ | 1x Web + 1x Accessories | [Repo](https://github.com/caieras/repo/blob/main/aws)
| AWS      | 🚧 WIP | 1x Web + 1x Accessories + AWS RDS | [Repo](https://github.com/caieras/repo)
| AWS      | 🚧 WIP | Multiple Web and Accessories + Load Balancer | [Repo](https://github.com/caieras/repo)

## Architecture Overview

This Terraform configuration creates (i) a public server ("web") designed to host the application and process background jobs, and (ii) a private server ("accessories") intended to run Redis for caching and job queuing, as well as a database.

## Prerequisites

- Terraform CLI installed. [Terraform Installation guide](https://developer.hashicorp.com/terraform/install)
- AWS CLI configured with appropriate credentials. [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- An [AWS Keypair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html) for SSH access to the servers.


## Usage

Clone this repository and initialize terraform.

```shell
git clone github.com
cd kamal-terraform-recipes
touch terraform.tfvars
terraform init
terraform plan
terraform apply
```

## Resources Created and environment variables

1. A Virtual Private Cloud (VPC)
2. Two EC2 instances: `web` and `accessories`
3. Internet Gateway
4. Public Subnets
5. Route Tables
6. Security Groups

### VPC
- CIDR block and DNS settings are configurable via variables

### EC2 Instances
1. Web Instance:
- AMI: Configurable via variable
- Instance Type: Configurable via variable
- Located in the first public subnet
- Assigned Elastic IP

2. Accessories Instance:
- AMI: Configurable via variable
- Instance Type: Configurable via variable
- Located in the second public subnet

### Networking
- Internet Gateway
- Public Subnets in multiple Availability Zones
- Route Tables for public subnets

### Security
- Public Security Group: Allows inbound traffic on ports `80`, `443`, and `22`.
- Private Security Group: Allows inbound traffic from the public security group.

> **Note:** The private security group serves as a barrier to isolate the private instance from direct internet access. Instead of using a NAT Gateway or NAT Instance, which would incur significant costs, we've choose to combines AWS security group policies with UFW rules on the instance itself. This dual-layer strategy blocks inbound traffic from the internet while still allowing necessary outbound connections.

## Cloud-Init Configuration

Both instances use cloud-init for initial setup configuration, including:
- Linux package updates
- Root user creation and SSH key setup
- Docker installation and private network configuration
- Uncomplicated Firewall (UFW) rules;
- Fail2ban installation.

> Fail2ban instalation step has been removed from cloud-init config due to [issues with Ubuntu 24.04](https://github.com/fail2ban/fail2ban/issues/3487#issuecomment-2094643059). If deploying with another Linux version, you can add the following to your cloud-init configuration:

```yml
# 1. In cloudinit/base.yml

packages:
  - docker.io
  - curl
  - git
  - snapd
  - ufw
  - fail2ban
# ...
runcmd:
# ... add before reboot:
- systemctl start fail2ban
- systemctl enable fail2ban
- service fail2ban start
- fail2ban-client status
```
## Variables

Key variables include:

| variable_name | type | default | _ 
|----------|----------|----------|----------
| web_instance_type | string | t4g.micro | 2vCPU, 1 GB RAM (free tier)
| db_instance_type | string | t4g.micro | 2vCPU, 1 GB RAM (free tier)
| ec2_ami | string | ami-0a4d44f3837d54a8a | Ubuntu Server 24.04 LTS (Arm64)
| key_name | string |app_staging | AWS key_name to be used on the servers 
| environment | string | staging | 
| app_tag | string | application | 
| availability_zones | list(string) | ["sa-east-1a", "sa-east-1c"] | 

Modify these in your `variables.tf` file or when prompted during `terraform apply`.

## Outputs
After running `terraform apply`, you'll see the instance IP addresses as output:

| Output | Description
|--------|------------
|web_instance_eip| Public IP for SSH access to the public instance
|accessories_instance_ip| Private IP for SSH access to the private instance

## Terraform Cloud Usage
To use a cloud back-end like HCP Terraform, provide credentials to access HCP Terraform by using the `terraform login` command.

Add a cloud block to the directory's Terraform configuration, to specify which organization and workspace to use, then run `terraform init`

```tf
terraform {
  cloud {
    organization = "YOUR-ORG-NAME"
    workspaces {
      name = "your-project-workspace"
    }
  }
}
```

Add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` as **sensitive environment variables** in your workspace at HCP Terraform.

## Cleaning Up

To remove all created resources:
`terraform destroy`

## Contributing
If you have ideas for improvements or encounter any issues, please open an issue or submit a pull request on our GitHub repository.
