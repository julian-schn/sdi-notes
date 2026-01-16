# Exercise 25 - Creating a Web Certificate
# Generates Let's Encrypt wildcard certificate using DNS-01 challenge

locals {
  # Use dns_zone as common_name if not specified
  cert_common_name = var.common_name != "" ? var.common_name : var.dns_zone
}

# Generate a private key for the ACME registration
resource "tls_private_key" "acme_registration" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Register with the ACME server
resource "acme_registration" "registration" {
  account_key_pem = tls_private_key.acme_registration.private_key_pem
  email_address   = var.email
}

# Generate a private key for the certificate
resource "tls_private_key" "certificate" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Request the certificate using DNS-01 challenge
resource "acme_certificate" "wildcard" {
  account_key_pem          = acme_registration.registration.account_key_pem
  common_name              = local.cert_common_name
  subject_alternative_names = ["*.${var.dns_zone}"]

  # Use RFC2136 DNS provider (dynamic DNS updates)
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

# Save the private key to a file
resource "local_file" "private_key" {
  content         = acme_certificate.wildcard.private_key_pem
  filename        = "${path.module}/gen/private.pem"
  file_permission = "0600"
}

# Save the certificate to a file
resource "local_file" "certificate" {
  content         = "${acme_certificate.wildcard.certificate_pem}${acme_certificate.wildcard.issuer_pem}"
  filename        = "${path.module}/gen/certificate.pem"
  file_permission = "0644"
}

# Save the full chain (certificate + issuer)
resource "local_file" "fullchain" {
  content         = "${acme_certificate.wildcard.certificate_pem}${acme_certificate.wildcard.issuer_pem}"
  filename        = "${path.module}/gen/fullchain.pem"
  file_permission = "0644"
}
