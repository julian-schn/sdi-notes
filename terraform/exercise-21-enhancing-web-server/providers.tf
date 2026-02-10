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
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "hcloud" {
}

provider "dns" {
  update {
    server        = "ns1.sdi.hdm-stuttgart.cloud"
    key_name      = "g2.key."
    key_algorithm = "hmac-sha512"
    key_secret    = var.dns_secret
  }
}
