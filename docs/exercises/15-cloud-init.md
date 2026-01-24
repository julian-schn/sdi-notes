# 15 - Cloud Init

> **Working Code:** [`terraform/exercise-15-cloud-init/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-15-cloud-init/)

## Overview
Replace inline bash scripts with a cloud-init template that provides comprehensive server bootstrapping including OS updates, SSH hardening, package installation, custom landing page, and firewall configuration.

## Prerequisites
- Completed [Exercise 14 - Nginx Automation](./14-nginx-automation.md)
- Understanding of YAML syntax
- Familiarity with cloud-init concepts

## Objective
Replace inline bash with a cloud-init template that updates the OS, hardens SSH, installs nginx/fail2ban/plocate, renders a landing page, and opens port 80; apply via Terraform.

## Implementation

### Step 1: Update Terraform to Use Cloud-Init Template
Switch the server's `user_data` to use a cloud-init template:

```hcl
user_data = templatefile("${path.module}/cloud-init.yaml", {
  server_name      = local.server_name
  ssh_public_keys  = concat([var.ssh_public_key], var.ssh_public_key_secondary != "" ? [var.ssh_public_key_secondary] : [])
  devops_username  = var.devops_username # defaults to "devops"
})
```

### Step 2: Create Cloud-Init Configuration
Example `cloud-init.yaml` for Debian 12:

```yaml
#cloud-config
hostname: ${server_name}
package_update: true
package_upgrade: true
package_reboot_if_required: true
ssh_pwauth: false
disable_root: true
packages: [nginx, ufw, fail2ban, plocate]
users:
  - default
  - name: ${devops_username}
    groups: [sudo]
    sudo: "ALL=(ALL) NOPASSWD:ALL"
    lock_passwd: true
    ssh_authorized_keys:
%{~ for key in ssh_public_keys ~}
      - ${key}
%{~ endfor ~}
write_files:
  - path: /etc/ssh/sshd_config.d/99-hardening.conf
    content: |
      PasswordAuthentication no
      PermitRootLogin no
  - path: /etc/fail2ban/jail.local
    content: |
      [DEFAULT]
      banaction = ufw
      backend = systemd
      maxretry = 5
      findtime = 10m
      bantime = 10m
      ignoreip = 127.0.0.1/8 ::1
      [sshd]
      enabled = true
  - path: /usr/local/bin/render-index.sh
    permissions: "0755"
    content: |
      #!/usr/bin/env bash
      ip=$(hostname -I | awk '{print $1}')
      ts=$(date -u +"%a %b %e %I:%M:%S %p %Z %Y")
      echo "I'm Nginx @ \"$ip\" created $ts" > /var/www/html/index.html
runcmd:
  - [bash, -lc, "export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get dist-upgrade -y"]
  - [systemctl, restart, ssh]
  - [bash, -lc, "ufw default deny incoming; ufw default allow outgoing; ufw allow 22/tcp; ufw allow 80/tcp; ufw --force enable"]
  - [systemctl, enable, --now, nginx]
  - [bash, -lc, "/usr/local/bin/render-index.sh"]
  - [systemctl, enable, --now, fail2ban]
  - [bash, -lc, "systemctl enable --now plocate-updatedb.timer; plocate-updatedb"]
```

### Step 3: Open HTTP Firewall Port in Terraform
Add firewall rule for HTTP:

```hcl
rule {
  direction = "in"
  protocol  = "tcp"
  port      = "80"
  source_ips = ["0.0.0.0/0", "::/0"]
}
```

### Step 4: Apply Configuration
Run `terraform apply` (or replace the server) to apply the new cloud-init configuration.

## Verification
1. Apply Terraform: `terraform apply`
2. Wait for cloud-init to complete (~2-3 minutes)
3. Check cloud-init status: `ssh devops@<server-ip> "sudo cloud-init status --wait"`
4. Verify HTTP access: Open `http://<server-ip>` in browser, should show "I'm Nginx @ &lt;ip&gt; created &lt;timestamp&gt;"
5. Verify SSH hardening: `ssh -v devops@<server-ip>` should only offer `publickey` authentication
6. Verify sudo access: `ssh devops@<server-ip> "sudo su -"` should work without password
7. Verify root SSH denied: `ssh root@<server-ip>` should be rejected
8. Verify fail2ban: `ssh devops@<server-ip> "sudo fail2ban-client status sshd"`
9. Verify packages updated: `ssh devops@<server-ip> "apt update"`
10. Verify plocate: `ssh devops@<server-ip> "locate ssh_host"`

## Problems & Learnings

::: warning Common Issues
*This section will be filled in collaboratively. Common issues encountered during this exercise will be documented here.*
:::

::: tip Key Takeaways
*Key learnings and best practices from this exercise will be documented here.*
:::

## Related Exercises
- [14 - Nginx Automation](./14-nginx-automation.md) - Basic nginx automation
- [16 - SSH Known Hosts](./16-ssh-known-hosts.md) - Managing SSH host keys
- [20 - Volume Auto](./20-volume-auto.md) - Using cloud-init for volume management
