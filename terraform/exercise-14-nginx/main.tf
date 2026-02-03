# Exercise 14 - Automatic Nginx Installation
# Builds on Exercise 13 by adding user_data for nginx automation

# Get all existing SSH keys to check if our public key already exists
data "hcloud_ssh_keys" "all" {}

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

# Data sources to lookup existing SSH keys (if reusing)
data "hcloud_ssh_key" "existing_primary" {
  count = var.existing_ssh_key_name != "" ? 1 : 0
  name  = var.existing_ssh_key_name
}

data "hcloud_ssh_key" "existing_secondary" {
  count = var.existing_ssh_key_secondary_name != "" ? 1 : 0
  name  = var.existing_ssh_key_secondary_name
}

# SSH Key Resource (conditional - only creates if not reusing existing)
resource "hcloud_ssh_key" "primary" {
  count      = local.should_create_primary_key ? 1 : 0
  name       = "ssh-key"
  public_key = var.ssh_public_key
}

# Secondary SSH Key (conditional - creates only if secondary key content provided and not reusing existing)
resource "hcloud_ssh_key" "secondary" {
  count      = var.ssh_public_key_secondary != "" && var.existing_ssh_key_secondary_name == "" ? 1 : 0
  name       = "ssh-key-secondary"
  public_key = var.ssh_public_key_secondary
}

# Collect all SSH key IDs
locals {
  # Find existing SSH key with matching public key
  existing_key_with_pubkey = try([
    for key in data.hcloud_ssh_keys.all.ssh_keys :
    key if key.public_key == var.ssh_public_key
  ][0], null)

  # Determine if we should create a new SSH key or use existing
  should_create_primary_key = var.existing_ssh_key_name == "" && local.existing_key_with_pubkey == null

  primary_ssh_key_id = var.existing_ssh_key_name != "" ? data.hcloud_ssh_key.existing_primary[0].id : (
    local.existing_key_with_pubkey != null ? local.existing_key_with_pubkey.id : hcloud_ssh_key.primary[0].id
  )

  secondary_ssh_key_id = var.ssh_public_key_secondary != "" ? (
    var.existing_ssh_key_secondary_name != "" ? data.hcloud_ssh_key.existing_secondary[0].id : hcloud_ssh_key.secondary[0].id
  ) : null

  ssh_key_ids = compact(concat(
    [local.primary_ssh_key_id],
    local.secondary_ssh_key_id != null ? [local.secondary_ssh_key_id] : []
  ))
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
