# 13 - Incrementally Creating a Base System

> **Working Code:** [`terraform/base/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/base/)

## Overview
Automatically create servers on Hetzner Cloud using Terraform. This exercise walks through incrementally building a base infrastructure configuration with proper security and access controls.

## Prerequisites
- Hetzner Cloud account with API token
- Terraform installed locally
- SSH key pair generated (`~/.ssh/id_ed25519.pub`)

## Objective
Start with a minimal hcloud server + firewall + outputs; store the API token in tfvars/ENV, add your SSH key to avoid passwords, then `terraform apply` to create and inspect the server.

## Implementation

### Step 1: Minimal Terraform Configuration
Start with a basic Terraform configuration:

```hcl
terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_server" "helloServer" {
  name        = "hello-server"
  server_type = "cx11"
  image       = "ubuntu-22.04"
  location    = "hel1"
}
```

### Step 2: Add Firewall for SSH
Create an inbound firewall rule to allow SSH access:

```hcl
resource "hcloud_firewall" "ssh" {
  name = "allow-ssh"
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}
```

### Step 3: Protect API Token
Store secrets in a separate file that won't be committed to git:

```hcl
# variables.tf
variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
}

# secrets.auto.tfvars (not in Git)
hcloud_token = "replace-me"
```

### Step 4: Initialize and Apply
Initialize Terraform and create the infrastructure:

```bash
terraform init
terraform apply
```

You will receive an email with the server's IP address and root password.

### Step 5: Switch to SSH Key Authentication
Add your SSH public key to avoid password authentication:

```hcl
resource "hcloud_ssh_key" "key" {
  name       = "ssh-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}
```

### Step 6: Reference SSH Key in Server Resource
Update the server resource to use the SSH key:

```hcl
resource "hcloud_server" "helloServer" {
  name        = "hello-server"
  server_type = "cx11"
  image       = "ubuntu-22.04"
  location    = "hel1"
  ssh_keys    = [hcloud_ssh_key.key.id]
}
```

### Step 7: Add Output Values
Create an `outputs.tf` file to display useful information:

```hcl
output "hello_ip_addr" {
  value = hcloud_server.helloServer.ipv4_address
}

output "hello_datacenter" {
  value = hcloud_server.helloServer.datacenter
}
```

### Step 8: Apply Changes
Run `terraform apply` to update the infrastructure with SSH key authentication and outputs.

## Verification
1. Initialize Terraform: `terraform init`
2. Apply configuration: `terraform apply`
3. Note the output IP address
4. Connect via SSH: `ssh root@<ip-address>`
5. Verify SSH key authentication works (no password prompt)

## Problems & Learnings

::: warning Common Issues
*This section will be filled in collaboratively. Common issues encountered during this exercise will be documented here.*
:::

::: tip Key Takeaways
*Key learnings and best practices from this exercise will be documented here.*
:::

## Related Exercises
- [14 - Nginx Automation](./14-nginx-automation.md) - Automating web server installation
- [15 - Cloud Init](./15-cloud-init.md) - Advanced server bootstrapping
