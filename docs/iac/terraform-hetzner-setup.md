# Terraform Hetzner Cloud Setup

This guide covers setting up infrastructure on Hetzner Cloud using Terraform.

## Prerequisites

- Terraform >= 1.0
- Hetzner Cloud account and API token

## Project Structure

```
terraform/
├── main.tf           # Provider configuration
├── variables.tf      # Input variables
├── resources.tf      # Infrastructure resources
├── outputs.tf        # Output values
├── terraform.tfvars  # Non-sensitive configuration
├── .env.example      # Environment template
└── .env              # Sensitive values (ignored by Git)
```

## Configuration Overview

The setup creates a cost-optimized Hetzner Cloud server with the following components:

- **Server**: cx22 instance in Nuremberg running Debian 12
- **SSH Keys**: Primary and optional secondary key deployment
- **Firewall**: SSH access with outbound traffic allowed
- **Network**: Public IPv4 and IPv6 addresses
- **Auto-naming**: Incremental server names (server-1, server-2, etc.)

## Initial Setup

### Environment Configuration

1. Navigate to the terraform directory:
```bash
cd terraform
```

2. Create environment file from template:
```bash
cp .env.example .env
```

3. Edit `.env` with your credentials:
```bash
export HCLOUD_TOKEN="API_TOKEN"
export TF_VAR_ssh_public_key="ssh-ed25519 ..." # required 
export TF_VAR_ssh_public_key_secondary=""  # not required 
```

4. Source the environment variables:
```bash
source .env
```

### Terraform Deployment

Initialize the working directory:
```bash
terraform init
```

Preview the planned changes:
```bash
terraform plan
```

Apply the configuration:
```bash
terraform apply
```

View the outputs:
```bash
terraform output
```

## Server Configuration

### Default Settings

The `terraform.tfvars` file contains the default configuration:

```hcl
server_base_name = "server"
server_type      = "cx23"
server_image     = "debian-13"
location         = "nbg1"
environment      = "development"
project          = "hello-world"
```

### Server Types

Servers we should use: 

- `cx23`: 2 vCPU, 4GB RAM (AMD/Intel, cost-effective)

### Locations

Supported datacenter locations:

- `nbg1`: Nuremberg, Germany
- `fsn1`: Falkenstein, Germany  
- `hel1`: Helsinki, Finland
- `ash`: Ashburn, USA
- `hil`: Hillsboro, USA

### Operating Systems

Common image options:

- `debian-13`: Debian 12
- `ubuntu-24.04`: Ubuntu 24.04 LTS
- `centos-stream-10`: CentOS Stream 10
- `fedora-42`: Fedora 42

## SSH Key Management

The configuration supports dual SSH key deployment:

### Primary SSH Key

Required for server access. Set via environment variable:
```bash
export TF_VAR_ssh_public_key="ssh-ed25519..."
```

Creates resource named: `{project}-primary-ssh-key`

### Secondary SSH Key

Optional for team access or backup. Set via environment variable:
```bash
export TF_VAR_ssh_public_key_secondary="ssh-rsa..."
```

Creates resource named: `{project}-secondary-ssh-key`

Leave empty to skip: `export TF_VAR_ssh_public_key_secondary=""`

## Auto-Incrementing Names

The configuration automatically generates server names:

- Scans existing servers matching the pattern `{base_name}-{number}`
- Finds the highest number and increments by one
- First server: `server-1`
- Second server: `server-2`
- Continues sequentially

## Network Configuration

### Public Networking

All servers are configured with:
- Public IPv4 address
- Public IPv6 address
- Full internet connectivity

### Firewall Rules

The firewall allows:
- **Inbound**: SSH (port 22) from any IP
- **Outbound**: All protocols and ports

## Server Initialization

The `user-data.sh` script runs on first boot:

```bash
#!/bin/bash
apt-get update && apt-get upgrade -y
apt-get install -y curl wget git htop vim ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw --force enable
```

This script:
- Updates system packages
- Installs essential tools
- Configures UFW firewall
- Enables SSH access

## Outputs

After successful deployment, Terraform provides:

```
server_id = "12345678"
server_name = "server-1"  
server_public_ipv4 = "1.2.3.4"
server_public_ipv6 = "2001:db8::1"
ssh_connection = "ssh root@1.2.3.4"
```

## Cleanup

To destroy all created resources:
```bash
terraform destroy
```

## State Management

Terraform maintains state locally in:
- `terraform.tfstate`: Current infrastructure state
- `terraform.tfstate.backup`: Previous state backup
