# Exercise 14 - Automatic Nginx Installation
# Builds on Exercise 13 by adding user_data for nginx automation

terraform {
  required_version = ">= 1.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.46"
    }
  }
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  # Token is automatically read from HCLOUD_TOKEN environment variable
}

# SSH Key Resource
resource "hcloud_ssh_key" "primary" {
  name       = "ssh-key"
  public_key = var.ssh_public_key
}

# Secondary SSH Key (optional)
resource "hcloud_ssh_key" "secondary" {
  count      = var.ssh_public_key_secondary != "" ? 1 : 0
  name       = "ssh-key-secondary"
  public_key = var.ssh_public_key_secondary
}

# Collect all SSH key IDs
locals {
  ssh_key_ids = concat(
    [hcloud_ssh_key.primary.id],
    var.ssh_public_key_secondary != "" ? [hcloud_ssh_key.secondary[0].id] : []
  )
}
# Firewall Resource - Allow SSH and HTTP
resource "hcloud_firewall" "web_server" {
  name = "allow-ssh-http"

  # SSH access
  rule {
    direction = "in"
    port      = "22"
    protocol  = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # HTTP access (NEW in Exercise 14)
  rule {
    direction = "in"
    port      = "80"
    protocol  = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Allow all outbound traffic
  rule {
    direction = "out"
    protocol  = "tcp"
    port      = "1-65535"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "out"
    protocol  = "udp"
    port      = "1-65535"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  labels = {
    managed_by = "terraform"
  }
}

# Hetzner Cloud Server Resource with Nginx
resource "hcloud_server" "nginx_server" {
  name        = var.server_name
  image       = var.server_image
  server_type = var.server_type
  location    = var.location

  # SSH Keys (primary + optional secondary)
  ssh_keys = local.ssh_key_ids

  # Firewall (now includes HTTP)
  firewall_ids = [hcloud_firewall.web_server.id]

  # Public network
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  # NEW: User data to automatically install Nginx
  user_data = file("${path.module}/nginx_setup.sh")
}
