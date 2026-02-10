# 14 - Nginx Automation

> **Working Code:** [`terraform/exercise-14-nginx/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-14-nginx/)

**The Problem:** The server from Exercise 13 is empty. You have to SSH in and install software manually.

**The Solution:** Use `user_data` to run a shell script automatically on first boot.

## How-to

### 1. Write the Script
```bash
#!/bin/bash
apt update
apt install -y nginx
systemctl start nginx
systemctl enable nginx
```

### 2. Pass to Terraform
```hcl
resource "hcloud_server" "web" {
  user_data = file("nginx_setup.sh")
}
```

### 3. Apply
```bash
terraform apply
# Wait ~60 seconds for apt update
curl http://<server_ip>  # Welcome to Nginx!
```

## Related Exercises
- [15 - Cloud-init](./15-cloud-init.md)
