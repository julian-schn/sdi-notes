# 14 - Automatic Nginx Installation

> **Working Code:** [`terraform/exercise-14-nginx/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-14-nginx/)

**The Problem:** The server from Exercise 13 is empty. You still have to SSH in and install software manually.

**The Solution:** Use `user_data` to pass a shell script that runs automatically on the first boot.

## How-to

### 1. Write the Script (`nginx_setup.sh`)
Simple bash commands to install and start the server:

```bash
#!/bin/bash
apt update
apt install -y nginx
systemctl start nginx
systemctl enable nginx
```

### 2. Pass it to Terraform
Read the file and pass it to the `user_data` argument:

```hcl
resource "hcloud_server" "web" {
  # ... (other config) ...
  user_data = file("nginx_setup.sh")
}
```

### 3. Apply
Running `terraform apply` will:
1. Create the server
2. Upload the script
3. Run it as root on first boot

## Verification
1. `terraform apply`
2. Wait ~60 seconds (apt update takes time!)
3. Visit `http://<server_ip>` -> Welcome to Nginx!

## Related Exercises
- [15 - Cloud Init](./15-cloud-init.md) - Doing this cleaner with YAML
