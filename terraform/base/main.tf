# Exercise 13 - Incrementally creating a base system
# Minimal Terraform configuration for Hetzner Cloud

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
  # or can be set via terraform.tfvars
}

# SSH Key Resource
resource "hcloud_ssh_key" "primary" {
  name       = "ssh-key"
  public_key = var.ssh_public_key
}

# Firewall Resource - Allow SSH
resource "hcloud_firewall" "ssh" {
  name = "allow-ssh"

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

# Hetzner Cloud Server Resource
resource "hcloud_server" "hello_server" {
  name        = var.server_name
  image       = var.server_image
  server_type = var.server_type
  location    = var.location

  # SSH Key
  ssh_keys = [hcloud_ssh_key.primary.id]

  # Firewall
  firewall_ids = [hcloud_firewall.ssh.id]

  # Public network
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}
