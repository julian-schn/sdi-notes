# Exercise 21 - Enhancing Web Server
# Sets up web server with Nginx and DNS records for TLS config

# Create Firewall (HTTP/HTTPS/SSH)
resource "hcloud_firewall" "server_firewall" {
  name  = "${var.project}-firewall"

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

# SSH Config - Check for existing keys first
data "hcloud_ssh_keys" "existing" {
  with_selector = "managed_by=terraform"
}

locals {
  # Find existing SSH keys by public key fingerprint
  existing_primary_key = try(
    one([for k in data.hcloud_ssh_keys.existing.ssh_keys : k if k.public_key == var.ssh_public_key]),
    null
  )
  existing_secondary_key = var.ssh_public_key_secondary != "" ? try(
    one([for k in data.hcloud_ssh_keys.existing.ssh_keys : k if k.public_key == var.ssh_public_key_secondary]),
    null
  ) : null
  
  should_create_primary_key   = local.existing_primary_key == null
  should_create_secondary_key = var.ssh_public_key_secondary != "" && local.existing_secondary_key == null
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
  count      = local.should_create_secondary_key ? 1 : 0
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
  
  # Use existing key ID or newly created key ID
  primary_ssh_key_id = local.should_create_primary_key ? hcloud_ssh_key.primary[0].id : local.existing_primary_key.id
  secondary_ssh_key_id = var.ssh_public_key_secondary != "" ? (
    local.should_create_secondary_key ? hcloud_ssh_key.secondary[0].id : local.existing_secondary_key.id
  ) : null
}

# Server
resource "hcloud_server" "web_server" {
  name        = var.server_name
  image       = var.server_image
  server_type = var.server_type
  location    = var.location

  ssh_keys = compact([
    local.primary_ssh_key_id,
    local.secondary_ssh_key_id
  ])

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
