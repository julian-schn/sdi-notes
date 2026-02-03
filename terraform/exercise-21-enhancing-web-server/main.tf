# Exercise 21 - Enhancing Web Server
# Sets up web server with Nginx and DNS records for TLS config

# Get all existing SSH keys to check if our public key already exists
data "hcloud_ssh_keys" "all" {}

# Create Firewall (HTTP/HTTPS/SSH)
resource "hcloud_firewall" "server_firewall" {
  name  = "${var.project}-web-server-firewall"

  # SSH
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # HTTP
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # HTTPS
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction = "out"
    protocol  = "tcp"
    port      = "1-65535"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }
  
  rule {
    direction = "out"
    protocol  = "udp"
    port      = "1-65535"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }

  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  }
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

resource "hcloud_ssh_key" "primary" {
  count      = local.should_create_primary_key ? 1 : 0
  name       = "${var.project}-primary-ssh-key"
  public_key = var.ssh_public_key
  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  }
}

resource "hcloud_ssh_key" "secondary" {
  count      = var.ssh_public_key_secondary != "" && var.existing_ssh_key_secondary_name == "" ? 1 : 0
  name       = "${var.project}-secondary-ssh-key"
  public_key = var.ssh_public_key_secondary
  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  }
}

locals {
  ssh_authorized_keys = concat(
    [var.ssh_public_key],
    var.ssh_public_key_secondary != "" ? [var.ssh_public_key_secondary] : []
  )

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

# Server
resource "hcloud_server" "web_server" {
  name        = var.server_name
  image       = var.server_image
  server_type = var.server_type
  location    = var.location

  ssh_keys = local.ssh_key_ids

  firewall_ids = [hcloud_firewall.server_firewall.id]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  }

  user_data = templatefile("${path.module}/cloud-init.yaml", {
    server_name     = var.server_name
    ssh_public_keys = local.ssh_authorized_keys
    devops_username = var.devops_username
  })
}

# DNS Configuration (HDM Stuttgart DNS Server)
# Record: g2.sdi.hdm-stuttgart.cloud -> server IP
# Note: hashicorp/dns provider doesn't support apex records, using nsupdate
resource "null_resource" "dns_root" {
  triggers = {
    server_ip  = hcloud_server.web_server.ipv4_address
    zone       = "${var.project}.sdi.hdm-stuttgart.cloud"
    project    = var.project
    dns_secret = var.dns_secret
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "server ns1.sdi.hdm-stuttgart.cloud
      update delete ${var.project}.sdi.hdm-stuttgart.cloud. A
      update add ${var.project}.sdi.hdm-stuttgart.cloud. 10 A ${hcloud_server.web_server.ipv4_address}
      send" | nsupdate -y "hmac-sha512:${var.project}.key:${var.dns_secret}"
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "server ns1.sdi.hdm-stuttgart.cloud
      update delete ${self.triggers.zone}. A
      send" | nsupdate -y "hmac-sha512:${self.triggers.project}.key:${self.triggers.dns_secret}" || true
    EOT
  }
}

# Record: www.g02.sdi.hdm-stuttgart.cloud -> server IP
resource "dns_a_record_set" "www" {
  zone      = "${var.project}.sdi.hdm-stuttgart.cloud."
  name      = "www"
  addresses = [hcloud_server.web_server.ipv4_address]
  ttl       = 10
}
