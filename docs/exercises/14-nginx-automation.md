# 14 - Automatic Nginx Installation

> **Working Code:** [`terraform/exercise-14-nginx/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-14-nginx/)

## Overview
Automate nginx installation and configuration during server provisioning using Terraform's user_data feature. This eliminates manual setup steps and ensures consistent server configuration.

## Prerequisites
- Completed [Exercise 13 - Base System](./13-base-system.md)
- Basic understanding of bash scripting
- Terraform configuration from previous exercise

## Objective
Write a small bash script that installs/enables nginx, then point Terraform `user_data` at it so new servers come up serving HTTP automatically.

## Implementation

### Step 1: Create Nginx Setup Script
Create a `nginx_setup.sh` file:

```bash
#!/bin/bash
# Update package list
apt update -y

# Install Nginx web server
apt install -y nginx

# Start Nginx immediately
systemctl start nginx

# Enable Nginx to start automatically on boot
systemctl enable nginx
```

### Step 2: Integrate into Terraform
Update your server resource to use the setup script:

```hcl
resource "hcloud_server" "Server" {
  name        = "nginx-server"
  server_type = "cx11"
  image       = "ubuntu-22.04"
  location    = "hel1"
  ssh_keys    = [hcloud_ssh_key.key.id]

  user_data = file("nginx_setup.sh")
}
```

### Step 3: Apply and Verify
Run `terraform apply` to create the server with nginx pre-installed:

```bash
terraform apply
```

Verify nginx is running:
```bash
systemctl status nginx
```

## Verification
1. Apply Terraform configuration: `terraform apply`
2. Wait for server to provision (1-2 minutes)
3. SSH into server: `ssh root@<server-ip>`
4. Check nginx status: `systemctl status nginx`
5. Verify nginx is active and enabled
6. Test web access: `curl http://localhost`

## Problems & Learnings

::: warning Common Issues
*This section will be filled in collaboratively. Common issues encountered during this exercise will be documented here.*
:::

::: tip Key Takeaways
*Key learnings and best practices from this exercise will be documented here.*
:::

## Related Exercises
- [13 - Base System](./13-base-system.md) - Foundation Terraform configuration
- [15 - Cloud Init](./15-cloud-init.md) - More advanced bootstrapping with cloud-init
