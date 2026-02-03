# Variables for Exercise 25 - Web Certificate

variable "dns_zone" {
  description = "DNS zone name (e.g., g2.sdi.hdm-stuttgart.cloud)"
  type        = string
  default     = "g2.sdi.hdm-stuttgart.cloud"
}

variable "project" {
  description = "Project/group name for DNS (e.g., g2)"
  type        = string
  default     = "g2"
}

variable "dns_secret" {
  description = "HMAC-SHA512 secret for HDM Stuttgart DNS"
  type        = string
  sensitive   = true
}

variable "email" {
  description = "Email address for Let's Encrypt registration"
  type        = string
  default     = "admin@example.com"
}

variable "use_production" {
  description = "Use production Let's Encrypt server (false = staging)"
  type        = bool
  default     = false  # IMPORTANT: Default to staging to avoid rate limits!
}

variable "common_name" {
  description = "Common name for the certificate (usually the apex domain)"
  type        = string
  default     = ""  # Defaults to dns_zone if empty
}

variable "existing_ssh_key_name" {
  description = "Name of existing primary SSH key in Hetzner Cloud (unused in this exercise, but required by Makefile)"
  type        = string
  default     = ""
}
