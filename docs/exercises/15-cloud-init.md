# 15 - Cloud Init

> **Working Code:** [`terraform/exercise-15-cloud-init/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-15-cloud-init/)

**The Problem:** Bash scripts (like in Exercise 14) are brittle. They don't handle errors well, are hard to read, and can't easily handle complex config like creating users or writing files.

**The Solution:** `cloud-init` is the industry standard for specific bootstrap config. It uses declarative YAML.

## Objective
Use a `cloud-init.yaml` template to:
1. Update OS packages
2. Harden SSH (disable password auth, disable root login)
3. Install Nginx, UFW, Fail2ban
4. Create a custom index.html

## How-to

### 1. The Cloud Config (`cloud-init.yaml`)
Instead of `#!/bin/bash`, we use `#cloud-config`. It's declarative:

```yaml
#cloud-config
hostname: web-server
package_update: true
package_upgrade: true

# Harden SSH automatically
ssh_pwauth: false
disable_root: true

packages:
  - nginx
  - fail2ban
  - ufw

# Create users cleanly
users:
  - name: devops
    groups: [sudo]
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3...

# Write files
write_files:
  - path: /var/www/html/index.html
    content: |
      <h1>Configured via Cloud-Init!</h1>

# Run arbitrary commands (if needed)
runcmd:
  - ufw allow 'Nginx Full'
  - ufw allow OpenSSH
  - ufw enable
```

### 2. Pass it to Terraform
We use `templatefile` to inject variables (like your SSH key) into the YAML:

```hcl
resource "hcloud_server" "web" {
  # ...
  user_data = templatefile("cloud-init.yaml", {
    ssh_key = var.my_public_key
  })
}
```

## Verification
1. `terraform apply`
2. Wait 2-3 minutes (it does a full OS upgrade, which takes time).
3. Check `http://<ip>` -> Should see your custom HTML.
4. Try to SSH as root: `ssh root@<ip>` -> **Permission denied** (Good! Root is disabled).
5. Login as devops: `ssh devops@<ip>` -> Success.

## Related Exercises
- [20 - Volume Auto](./20-volume-auto.md) - Using cloud-init to mount disks
