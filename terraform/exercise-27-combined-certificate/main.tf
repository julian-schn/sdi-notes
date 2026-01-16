# Exercise 27 - Combining Certificate Generation and Server Creation
# Complete all-in-one solution: certificate + DNS + server with SSL

locals {
  ssh_authorized_keys = concat(
    [var.ssh_public_key],
    var.ssh_public_key_secondary != "" ? [var.ssh_public_key_secondary] : []
  )
  
  dns_zone_with_dot = "${var.dns_zone}."
}

# ============================================================================
# PART 1: CERTIFICATE GENERATION (from Exercise 25)
# ============================================================================

# Private key for ACME registration
resource "tls_private_key" "acme_registration" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Register with ACME server
resource "acme_registration" "registration" {
  account_key_pem = tls_private_key.acme_registration.private_key_pem
  email_address   = var.email
}

# Request wildcard certificate
resource "acme_certificate" "wildcard" {
  account_key_pem           = acme_registration.registration.account_key_pem
  common_name               = var.dns_zone
  subject_alternative_names = ["*.${var.dns_zone}"]

  dns_challenge {
    provider = "rfc2136"

    config = {
      RFC2136_NAMESERVER     = "ns1.sdi.hdm-stuttgart.cloud"
      RFC2136_TSIG_ALGORITHM = "hmac-sha512"
      RFC2136_TSIG_KEY       = "${var.project}.key."
      RFC2136_TSIG_SECRET    = var.dns_secret
    }
  }
}

# Save certificate files locally
resource "local_file" "private_key" {
  content         = acme_certificate.wildcard.private_key_pem
  filename        = "${path.module}/gen/private.pem"
  file_permission = "0600"
}

resource "local_file" "certificate" {
  content         = "${acme_certificate.wildcard.certificate_pem}${acme_certificate.wildcard.issuer_pem}"
  filename        = "${path.module}/gen/certificate.pem"
  file_permission = "0644"
}

# ============================================================================
# PART 2: SERVER CREATION (from Exercise 26)
# ============================================================================

# SSH Key
resource "hcloud_ssh_key" "primary" {
  name       = "${var.project}-combined-ssh-key"
  public_key = var.ssh_public_key

  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  }
}

# Firewall with SSH, HTTP, HTTPS
resource "hcloud_firewall" "server_firewall" {
  name = "${var.project}-combined-firewall"

  rule {
    direction  = "in"
    port       = "22"
    protocol   = "tcp"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    port       = "80"
    protocol   = "tcp"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    port       = "443"
    protocol   = "tcp"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction       = "out"
    protocol        = "tcp"
    port            = "1-65535"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction       = "out"
    protocol        = "udp"
    port            = "1-65535"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }

  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  }
}

# Server with certificate installed
resource "hcloud_server" "web_server" {
  name        = "${var.project}-combined"
  image       = var.server_image
  server_type = var.server_type
  location    = var.location

  ssh_keys     = [hcloud_ssh_key.primary.id]
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

  # Cloud-init with certificate embedded
  user_data = templatefile("${path.module}/cloud-init.yaml", {
    server_name         = var.dns_zone
    ssh_public_keys     = local.ssh_authorized_keys
    devops_username     = var.devops_username
    certificate_content = base64encode("${acme_certificate.wildcard.certificate_pem}${acme_certificate.wildcard.issuer_pem}")
    private_key_content = base64encode(acme_certificate.wildcard.private_key_pem)
    dns_zone            = var.dns_zone
  })

  # Ensure certificate is generated first
  depends_on = [acme_certificate.wildcard]

  lifecycle {
    create_before_destroy = true
  }
}

# ============================================================================
# PART 3: DNS RECORDS
# ============================================================================

# DNS A record for apex domain
resource "dns_a_record_set" "apex" {
  zone      = local.dns_zone_with_dot
  name      = "@"
  addresses = [hcloud_server.web_server.ipv4_address]
  ttl       = 10
}

# DNS A records for each server name
resource "dns_a_record_set" "names" {
  count     = length(var.server_names)
  zone      = local.dns_zone_with_dot
  name      = var.server_names[count.index]
  addresses = [hcloud_server.web_server.ipv4_address]
  ttl       = 10
}

# ============================================================================
# PART 4: SSH HELPERS
# ============================================================================

resource "null_resource" "known_hosts" {
  depends_on = [hcloud_server.web_server, dns_a_record_set.apex]

  triggers = {
    server_ip = hcloud_server.web_server.ipv4_address
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      mkdir -p "${path.module}/gen"
      
      echo "Waiting for SSH on ${var.dns_zone}..."
      for i in {1..30}; do
        if ssh-keyscan -t ed25519 -T 5 ${var.dns_zone} 2>/dev/null | grep -q "ssh-ed25519"; then
          ssh-keyscan -t ed25519 ${var.dns_zone} > "${path.module}/gen/known_hosts" 2>/dev/null
          echo "Host keys saved"
          exit 0
        fi
        sleep 5
      done
      exit 1
    EOT
  }
}

resource "local_file" "ssh_wrapper" {
  content = templatefile("${path.module}/tpl/ssh.sh", {
    devopsUsername = var.devops_username
    hostname       = var.dns_zone
  })

  filename        = "${path.module}/bin/ssh"
  file_permission = "0755"
}
