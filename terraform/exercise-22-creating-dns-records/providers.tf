terraform {
  required_version = ">= 1.0"

  required_providers {
    hetznerdns = {
      source  = "timohirt/hetznerdns"
      version = "2.2.0"
    }
  }
}

provider "hetznerdns" {
  # Token should be provided via HETZNER_DNS_TOKEN env var
}
