# Exercise 19 - Manual Volumes
# Introduces Hetzner Volumes with manual partitioning and mounting

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

# Primary SSH Key Resource
resource "hcloud_ssh_key" "primary" {
  name       = "${var.project}-primary-ssh-key"
  public_key = var.ssh_public_key

  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  }
}

# Secondary SSH Key Resource (optional)
resource "hcloud_ssh_key" "secondary" {
  count      = var.ssh_public_key_secondary != "" ? 1 : 0
  name       = "${var.project}-secondary-ssh-key"
  public_key = var.ssh_public_key_secondary

  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  }
}

# Firewall for this exercise
resource "hcloud_firewall" "server_firewall" {
  name = "${var.project}-firewall"

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

  # HTTP access
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
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  }
}

# Local values
locals {
  ssh_authorized_keys = concat(
    [var.ssh_public_key],
    var.ssh_public_key_secondary != "" ? [var.ssh_public_key_secondary] : []
  )
}

# Hetzner Cloud Server Resource
resource "hcloud_server" "main_server" {
  name        = var.server_name
  image       = var.server_image
  server_type = var.server_type
  location    = var.location

  # SSH Keys
  ssh_keys = concat(
    [hcloud_ssh_key.primary.id],
    var.ssh_public_key_secondary != "" ? [hcloud_ssh_key.secondary[0].id] : []
  )

  # Firewall
  firewall_ids = [hcloud_firewall.server_firewall.id]

  # Network configuration
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  # Labels
  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  }

  # Cloud-init configuration
  user_data = templatefile("${path.module}/cloud-init.yaml", {
    server_name     = var.server_name
    ssh_public_keys = local.ssh_authorized_keys
    devops_username = var.devops_username
  })

  # Lifecycle management
  lifecycle {
    create_before_destroy = true
  }
}

# NEW: Create a Volume
resource "hcloud_volume" "data_volume" {
  name      = "${var.project}-volume"
  size      = 10 # GB
  location  = var.location
  format    = "ext4" # Format on creation (Hetzner feature)
  
  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  }
}

# NEW: Attach Volume to Server
resource "hcloud_volume_attachment" "main_attachment" {
  volume_id = hcloud_volume.data_volume.id
  server_id = hcloud_server.main_server.id
  automount = true # Automount on the server side
}

# Use the SshKnownHosts module
module "ssh_known_hosts" {
  source = "../modules/SshKnownHosts"

  server_ip       = hcloud_server.main_server.ipv4_address
  devops_username = var.devops_username
}
