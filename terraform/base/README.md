# Exercise 13 - Incrementally Creating a Base System

This is the foundation exercise that creates a minimal Hetzner Cloud infrastructure with Terraform.

## What You'll Learn

- Basic Terraform configuration
- Creating a Hetzner Cloud server
- Setting up SSH access
- Configuring firewall rules
- Managing outputs

## What's Included

This configuration creates:

1. **SSH Key Resource** - Uploads your public SSH key to Hetzner Cloud
2. **Firewall** - Allows SSH (port 22) inbound and all outbound traffic
3. **Server** - A basic Ubuntu server with the firewall attached

## Prerequisites

- Hetzner Cloud account with API token
- Terraform installed (>= 1.0)
- SSH key pair generated

## Usage

1. **Copy the example variables file:**

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars` with your values:**

   ```hcl
   ssh_public_key = file("~/.ssh/id_ed25519.pub")
   # Optional overrides:
   # server_name = "server"
   # location    = "nbg1"
   ```

3. **Set your Hetzner API token:**

   ```bash
   export HCLOUD_TOKEN="replace-me"
   ```

   Or add it to `terraform.tfvars` (not recommended for security).

4. **Initialize Terraform:**

   ```bash
   terraform init
   ```

5. **Preview the changes:**

   ```bash
   terraform plan
   ```

6. **Apply the configuration:**

   ```bash
   terraform apply
   ```

7. **Access your server:**

   ```bash
   ssh root@$(terraform output -raw server_ip)
   ```

## Outputs

After applying, you'll see:

- `server_ip` - IPv4 address to SSH into
- `server_ipv6` - IPv6 address
- `server_datacenter` - Where your server is located
- `server_status` - Server status (should be "running")

## Next Steps

- **Exercise 14**: Add automatic Nginx installation using `user_data`
- **Exercise 15**: Implement advanced cloud-init configuration
- **Exercise 16**: Solve SSH known_hosts challenges
- **Exercise 17**: Generate host metadata with modules

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Note:** This will delete your server and all associated resources!
