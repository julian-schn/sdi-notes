# Exercise 25 - Creating a Web Certificate
# Uses ACME provider to generate Let's Encrypt wildcard certificates

terraform {
  required_version = ">= 1.0"

  required_providers {
    acme = {
      source = "vancluever/acme"
      # Version not specified to get latest (required for DNS provider compatibility)
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

# ACME provider configuration
# IMPORTANT: Use staging URL during testing to avoid rate limits!
provider "acme" {
  server_url = var.use_production ? "https://acme-v02.api.letsencrypt.org/directory" : "https://acme-staging-v02.api.letsencrypt.org/directory"
}

provider "tls" {}
provider "local" {}
