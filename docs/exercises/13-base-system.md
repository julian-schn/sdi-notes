# 13 - Base System

> **Working Code:** [`terraform/base/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/base/)

**The Problem:** Clicking through a web console to create servers is slow, unrepeatable, and prone to human error.

**The Solution:** Terraform lets you define infrastructure as code. Run one command to spin up your stack.

## Objective
Create a Hetzner server with **SSH key authentication** (secure) instead of a root password (insecure).

## How-to

### 1. Define the Provider
Tell Terraform we're using Hetzner Cloud (`hcloud`) and pass the token variable:

```hcl
provider "hcloud" {
  token = var.hcloud_token
}
```

### 2. Add your SSH Key
Don't use passwords. Upload your public key so the server lets you in automatically:

```hcl
resource "hcloud_ssh_key" "default" {
  name       = "julian-ssh-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}
```

### 3. Create the Server
Link the server to the key you just created:

```hcl
resource "hcloud_server" "web" {
  name        = "nginx-server"
  image       = "ubuntu-22.04"
  server_type = "cx11"
  location    = "hel1"
  ssh_keys    = [hcloud_ssh_key.default.id] # <--- Important!
}
```

### 4. Create the Firewall
Open port 22 (SSH). **Default deny** is safer than default allow:

```hcl
resource "hcloud_firewall" "ssh" {
  name = "ssh-access"
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}
```

### 5. Outputs
Print the IP at the end so you don't have to go looking for it:

```hcl
output "server_ip" {
  value = hcloud_server.web.ipv4_address
}
```

## Verification
1. `terraform init` (download plugin)
2. `terraform apply` (create resources)
3. SSH in: `ssh root@<output_ip>` -> Should log in **without** a password.

## Related Exercises
- [14 - Nginx Automation](./14-nginx-automation.md) - Making the server actually do something
