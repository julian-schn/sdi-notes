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

# Data source to lookup existing firewalls
data "hcloud_firewalls" "existing" {
  with_selector = "managed_by=terraform"
}

# Local to determine if we should create a new firewall
locals {
  # Try to find existing web server firewall by name
  existing_firewall = try(
    one([for fw in data.hcloud_firewalls.existing.firewalls : fw if fw.name == "allow-ssh-http"]),
    null
  )
  should_create_firewall = local.existing_firewall == null
}

# Firewall Resource - Allow SSH and HTTP (created only if it doesn't exist)
resource "hcloud_firewall" "web_server" {
  count = local.should_create_firewall ? 1 : 0
  
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

# Local to reference either existing or newly created firewall
locals {
  firewall_id = local.should_create_firewall ? hcloud_firewall.web_server[0].id : local.existing_firewall.id
}

# Hetzner Cloud Server Resource with Nginx
resource "hcloud_server" "nginx_server" {
  name        = var.server_name
  image       = var.server_image
  server_type = var.server_type
  location    = var.location

  # SSH Key
  ssh_keys = [hcloud_ssh_key.primary.id]

  # Firewall (now includes HTTP)
  firewall_ids = [local.firewall_id]

  # Public network
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  # NEW: User data to automatically install Nginx
  user_data = file("${path.module}/nginx_setup.sh")
}
