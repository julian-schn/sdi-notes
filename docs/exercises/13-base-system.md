# 13 - Incrementally creating a base system

> **Working Code:** [`terraform/base/`](../../terraform/base/)

- Automatically create servers on Hetzner Cloud using Terraform

TLDR: start with a minimal hcloud server + firewall + outputs; store the API token in tfvars/ENV, add your SSH key to avoid passwords, then `terraform apply` to create and inspect the server.

1. Start with minimal Terraform config (example):
```hcl
terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_server" "helloServer" {
  name        = "hello-server"
  server_type = "cx11"
  image       = "ubuntu-22.04"
  location    = "hel1"
}
```
2. Add inbound firewall rule for ssh
```hcl
resource "hcloud_firewall" "ssh" {
  name = "allow-ssh"
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}
```
3. Enter Hetzner API token after following commands
```hcl
terraform init
terraform apply
```
4. you get email with ip + root pw
5. protect API key (store secrets in other file)
```hcl
# variables.tf
variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
}

# secrets.auto.tfvars (not in Git)
hcloud_token = "your-actual-token"
```
6. switch from pw login to ssh
```hcl
resource "hcloud_ssh_key" "key" {
  name       = "ssh-key"
  public_key = file("~/.ssh/id_ed25519.pub")
} # add to terraform resource
```
7. reference in server resource
```hcl
resource "hcloud_server" "helloServer" {
  name        = "hello-server"
  server_type = "cx11"
  image       = "ubuntu-22.04"
  location    = "hel1"
  ssh_keys    = [hcloud_ssh_key.key.id]
}
```
8. add output values, add ``outputs.tf``
```hcl
output "hello_ip_addr" {
  value = hcloud_server.helloServer.ipv4_address
}

output "hello_datacenter" {
  value = hcloud_server.helloServer.datacenter
}
```
9. run ``terraform apply``
