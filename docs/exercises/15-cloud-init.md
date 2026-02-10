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

## Related Exercises
- [20 - Volume Auto](./20-volume-auto.md)
