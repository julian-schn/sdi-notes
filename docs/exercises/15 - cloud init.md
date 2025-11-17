# 15 - Cloud Init
TLDR: replace inline bash with a cloud-init template that updates the OS, hardens SSH, installs nginx/fail2ban/plocate, renders a landing page, and opens port 80; apply via Terraform.

1. switch Terraform server `user_data` to a cloud-init template to bootstrap everything in one go:
```hcl
user_data = templatefile("${path.module}/cloud-init.yaml", {
  server_name      = local.server_name
  ssh_public_keys  = concat([var.ssh_public_key], var.ssh_public_key_secondary != "" ? [var.ssh_public_key_secondary] : [])
  devops_username  = var.devops_username # defaults to "devops"
})
```
2. example `cloud-init.yaml` (Debian 12) that updates the OS, serves a custom page via Nginx, hardens SSH, and installs tooling:
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
3. open firewall for HTTP in Terraform:
```hcl
rule {
  direction = "in"
  protocol  = "tcp"
  port      = "80"
  source_ips = ["0.0.0.0/0", "::/0"]
}
```
4. `terraform apply` (or replace the server) to apply the new cloud-init on create.
5. verify:
- browser: `http://<server-ip>` shows “I'm Nginx @ "<ip>" created <timestamp>”
- SSH: `ssh -v devops@<server-ip>` offers `publickey` only; `sudo su -` works via group `sudo`
- root SSH login is denied
- `fail2ban-client status sshd` counts failed attempts/bans after bad logins
- `apt update` reports all packages up to date; `locate ssh_host` finds host key files after plocate index. 
