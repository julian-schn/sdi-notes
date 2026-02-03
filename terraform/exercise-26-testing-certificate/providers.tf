# Exercise 26 - Testing Your Web Certificate
# Providers configuration for self-contained certificate generation

terraform {
  required_version = ">= 1.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.46"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "~> 3.4"
    }
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

# Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}

# DNS Provider (RFC2136 - Dynamic DNS)
provider "dns" {
  update {
    server        = "ns1.sdi.hdm-stuttgart.cloud"
    key_algorithm = "hmac-sha512"
    key_name      = "${var.project}.key."
    key_secret    = var.dns_secret
  }
}

# ACME provider for Let's Encrypt certificates
provider "acme" {
  # Start with staging to avoid rate limits
  # Switch to production after successful testing
  server_url = var.use_production ? "https://acme-v02.api.letsencrypt.org/directory" : "https://acme-staging-v02.api.letsencrypt.org/directory"
}
