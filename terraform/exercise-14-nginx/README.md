# Exercise 14 - Automatic Nginx Installation

This exercise builds on Exercise 13 by adding automatic Nginx installation using `user_data`.

## What's New in Exercise 14

- **HTTP Firewall Rule** - Opens port 80 for web traffic
- **User Data Script** - `nginx_setup.sh` runs automatically on server creation
- **Nginx Output** - Direct URL to access your web server

## What You'll Learn

- Using `user_data` to automate server configuration
- Installing and enabling services on boot
- Opening additional firewall ports
- Testing web services

## What's Included

This configuration creates:

1. **SSH Key** - Your public key for access
2. **Firewall** - SSH (22) and HTTP (80) inbound, all outbound
3. **Server** - Ubuntu server that automatically installs Nginx
4. **User Data** - Bash script that runs on first boot

## Prerequisites

- Completed Exercise 13 or understand the basics
- Hetzner Cloud account with API token
- Terraform installed (>= 1.0)

## Usage

1. **Copy the example variables file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars`:**
   ```hcl
   ssh_public_key = file("~/.ssh/id_ed25519.pub")
   ```

3. **Set your Hetzner API token:**
   ```bash
   export HCLOUD_TOKEN="your-api-token-here"
   ```

4. **Initialize and apply:**
   ```bash
   terraform init
   terraform apply
   ```

5. **Get the Nginx URL:**
   ```bash
   terraform output nginx_url
   ```

6. **Visit in your browser or test with curl:**
   ```bash
   curl $(terraform output -raw nginx_url)
   ```
   You should see the default Nginx welcome page!

## Verification

SSH into your server and check Nginx status:

```bash
ssh root@$(terraform output -raw server_ip)
systemctl status nginx
```

You should see Nginx is `active (running)` and `enabled`.

## How It Works

The `nginx_setup.sh` script:

1. Updates package lists (`apt-get update`)
2. Installs Nginx (`apt-get install -y nginx`)
3. Starts Nginx immediately (`systemctl start`)
4. Enables Nginx to start on boot (`systemctl enable`)

The `user_data` parameter in the server resource tells Hetzner Cloud to run this script on first boot.

## Troubleshooting

**Nginx not running?**
- Check cloud-init logs: `cat /var/log/cloud-init-output.log`
- The script runs as root during provisioning

**Can't access port 80?**
- Verify firewall rule in Hetzner Cloud console
- Check with: `curl -v http://your-server-ip`

## Next Steps

- **Exercise 15**: Use cloud-init for more advanced configuration
- **Exercise 16**: Solve SSH known_hosts challenges
- **Exercise 17**: Generate host metadata with modules

## Cleanup

```bash
terraform destroy
```
