# 15 - Cloud-init

> **Working Code:** [`terraform/exercise-15-cloud-init/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-15-cloud-init/)

**The Problem:** Bash scripts (Exercise 14) are brittle, don't handle errors well, and can't easily manage complex config.

**The Solution:** `cloud-init` is the industry standard for bootstrap configuration. Uses declarative YAML.

## Objective
Use `cloud-init.yaml` to:
1. Update OS packages
2. Harden SSH (disable password auth, disable root)
3. Install Nginx, UFW, Fail2ban
4. Create custom index.html

## How-to

### 1. Cloud Config
```yaml
#cloud-config
hostname: web-server
package_update: true
package_upgrade: true

ssh_pwauth: false
disable_root: true

packages:
  - nginx
  - fail2ban
  - ufw

users:
  - name: devops
    groups: [sudo]
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${ssh_key}

write_files:
  - path: /var/www/html/index.html
    content: |
      <h1>Configured via Cloud-Init!</h1>

runcmd:
  - ufw allow 'Nginx Full'
  - ufw allow OpenSSH
  - ufw enable
```

### 2. Pass to Terraform
```hcl
resource "hcloud_server" "web" {
  user_data = templatefile("cloud-init.yaml", {
    ssh_key = var.my_public_key
  })
}
```

## Verification
```bash
terraform apply
# Wait ~2-3 mins (OS upgrade)
curl http://<ip>  # See custom HTML
ssh root@<ip>     # Permission denied (good!)
ssh devops@<ip>   # Success
```

## Problems & Learnings

::: warning Common Issues
- **`cloud-init status: done` but nothing installed** — caused by the `%{~ for ~}` template syntax stripping the newline after `ssh_authorized_keys:`, producing invalid YAML. Cloud-init silently skips the entire config. Fix: use `%{ for ~}` (no leading `~`) so the newline is preserved. Diagnose with `sudo cat /var/log/cloud-init-output.log`.
- **`plocate-updatedb: command not found`** — `plocate-updatedb` is the systemd service name, not a binary. The correct command is `updatedb`.
- **Terraform provisioning takes 5+ minutes** — caused by `package_reboot_if_required: true`. If a kernel upgrade is pulled, the server reboots mid-provisioning and the Hetzner provider waits through the reboot. Set to `false` for initial provisioning.
:::

::: tip Key Takeaways
- Always check `/var/log/cloud-init-output.log` when cloud-init reports `done` but the server isn't configured — the exit status can be misleading
- Terraform template `~` strip markers eat adjacent newlines; a leading `~` on a `for` loop removes the newline before it, which breaks YAML list syntax
- `package_update: true` + `package_upgrade: true` already handle upgrades — a redundant `apt-get dist-upgrade` in `runcmd` doubles the work
:::

## Related Exercises
- [20 - Volume Auto](./20-volume-auto.md)
