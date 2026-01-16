# Exercise 15 - Cloud-init Configuration

This exercise introduces **cloud-init**, a powerful industry-standard tool for automating server initialization. We replace the simple bash script from Exercise 14 with a comprehensive cloud-init configuration.

## What's New in Exercise 15

- **Cloud-init Template** - Replaces simple bash with declarative YAML configuration
- **Multiple SSH Keys** - Support for primary and secondary keys
- **DevOps User** - Creates a non-root user with sudo access
- **SSH Hardening** - Disables password auth and root login
- **UFW Firewall** - Host-level firewall configuration
- **Fail2ban** - Automatic IP banning for failed SSH attempts
- **Custom Landing Page** - Nginx serves page with server IP and creation time
- **Additional Tools** - git, vim, htop, plocate for better developer experience

## What You'll Learn

- Using cloud-init for comprehensive server configuration
- Creating non-root users with sudo access
- SSH hardening and security best practices
- Host-based firewall management with UFW
- Intrusion prevention with Fail2ban
- Template variables in Terraform

## Prerequisites

- Understanding of Exercises 13-14
- Hetzner Cloud account with API token
- Terraform installed (>= 1.0)
- SSH key pair

## Usage

1. **Copy the example variables file:**

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars`:**

   ```hcl
   ssh_public_key = file("~/.ssh/id_ed25519.pub")
   # Optional second key:
   # ssh_public_key_secondary = file("~/.ssh/id_rsa.pub")
   devops_username = "devops"  # or your preferred username
   ```

3. **Set your Hetzner API token:**

   ```bash
   export HCLOUD_TOKEN="replace-me"
   ```

4. **Initialize and apply:**

   ```bash
   terraform init
   terraform apply
   ```

5. **Wait for cloud-init to complete** (2-3 minutes):

   ```bash
   # Get the SSH command from output
   terraform output ssh_command

   # SSH as devops user (NOT root!)
   ssh devops@$(terraform output -raw server_ip)
   ```

## Verification

### 1. Check Nginx Landing Page

```bash
curl $(terraform output -raw nginx_url)
```

You should see: `I'm Nginx @ "X.X.X.X" created Mon Jan 01 12:00:00 PM UTC 2025`

### 2. Verify SSH Configuration

```bash
ssh devops@$(terraform output -raw server_ip)

# Once logged in:
# Check root login is disabled (should fail)
sudo su -

# Check SSH config
cat /etc/ssh/sshd_config.d/99-hardening.conf
```

### 3. Check Fail2ban

```bash
sudo fail2ban-client status sshd
```

### 4. Verify UFW Firewall

```bash
sudo ufw status
```

Should show:

```
Status: active
To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
80/tcp                     ALLOW       Anywhere
```

### 5. Check Package Updates

```bash
sudo apt update
# Should show all packages are up to date
```

### 6. Test plocate

```bash
locate ssh_host
# Should find SSH host key files
```

## How It Works

### Cloud-init Process

1. **Package Management**: Updates and upgrades all packages
2. **User Creation**: Creates devops user with sudo access
3. **File Writing**: Creates config files before services start
4. **Command Execution**: Runs commands in order via `runcmd`

### Template Variables

The `cloud-init.yaml` file uses Terraform template variables:

- `${server_name}` - Server hostname
- `${ssh_public_keys}` - Array of SSH keys (looped)
- `${devops_username}` - Username for non-root account

### Security Features

- **No Password Authentication**: Only SSH keys work
- **No Root Login**: Must use devops user and sudo
- **Fail2ban**: Bans IPs after 5 failed attempts in 10 minutes
- **UFW Firewall**: Only ports 22 and 80 are open
- **Automatic Updates**: System fully updated on first boot

## Troubleshooting

**Cloud-init still running?**

```bash
cloud-init status --wait
# Or check logs:
cat /var/log/cloud-init-output.log
```

**Can't SSH as devops?**

- Check you're using the correct username (not root)
- Verify SSH key is in terraform.tfvars
- Wait for cloud-init to complete

**Nginx not showing custom page?**

- Check if script ran: `sudo cat /var/www/html/index.html`
- Check cloud-init logs for errors

**Fail2ban not working?**

```bash
sudo systemctl status fail2ban
sudo fail2ban-client ping
```

## Next Steps

- **Exercise 16**: Solve SSH known_hosts challenges with helper scripts
- **Exercise 17**: Generate host metadata using Terraform modules

## Cleanup

```bash
terraform destroy
```

## Learn More

- [Cloud-init Documentation](https://cloudinit.readthedocs.io/)
- [Cloud-init Examples](https://cloudinit.readthedocs.io/en/latest/reference/examples.html)
- [UFW Documentation](https://help.ubuntu.com/community/UFW)
- [Fail2ban Documentation](https://www.fail2ban.org/)
