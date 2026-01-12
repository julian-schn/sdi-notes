# Exercise 22 - Creating DNS Records
# Uses hashicorp/dns provider to create A and CNAME records on HDM Stuttgart DNS server

terraform {
  required_version = ">= 1.0"

  required_providers {
    dns = {
      source  = "hashicorp/dns"
      version = "~> 3.4"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

# Configure the DNS provider for HDM Stuttgart DNS server
provider "dns" {
  update {
    server        = "ns1.sdi.hdm-stuttgart.cloud"
    key_name      = "${var.project}.key."
    key_algorithm = "hmac-sha512"
    key_secret    = var.dns_secret
  }
}
