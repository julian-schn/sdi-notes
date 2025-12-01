# Exercise 20 - Automated Volumes
# Automates volume formatting and mounting using Cloud-init

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

# Data source to lookup existing firewalls with matching labels
data "hcloud_firewalls" "existing" {
  with_selector = "project=${var.project},managed_by=terraform"
}

# Local to determine if we should create a new firewall
locals {
  # Try to find existing firewall by name
  existing_firewall = try(
    one([for fw in data.hcloud_firewalls.existing.firewalls : fw if fw.name == "${var.project}-firewall"]),
    null
  )
  should_create_firewall = local.existing_firewall == null
}

# Create firewall only if it doesn't exist
resource "hcloud_firewall" "server_firewall" {
  count = local.should_create_firewall ? 1 : 0
  
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

# Local to reference either existing or newly created firewall
locals {
  firewall_id = local.should_create_firewall ? hcloud_firewall.server_firewall[0].id : local.existing_firewall.id
}

# Local values
locals {
  ssh_authorized_keys = concat(
    [var.ssh_public_key],
    var.ssh_public_key_secondary != "" ? [var.ssh_public_key_secondary] : []
  )
}

# Create a Volume
resource "hcloud_volume" "data_volume" {
  name      = "${var.project}-volume"
  size      = 10 # GB
  location  = var.location
  # format    = "ext4" # We will format via cloud-init instead for practice
  
  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  }
}

# Attach Volume to Server
resource "hcloud_volume_attachment" "main_attachment" {
  volume_id = hcloud_volume.data_volume.id
  server_id = hcloud_server.main_server.id
  automount = false # We will mount via cloud-init
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
  firewall_ids = [local.firewall_id]

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
    volume_device   = hcloud_volume.data_volume.linux_device
  })

  # Lifecycle management
  lifecycle {
    create_before_destroy = true
  }
}

# Use the SshKnownHosts module
module "ssh_known_hosts" {
  source = "../modules/SshKnownHosts"

  server_ip       = hcloud_server.main_server.ipv4_address
  devops_username = var.devops_username
}
