# Variables for Exercise 27 - Combined Certificate

variable "server_type" {
  description = "Server type/size"
  type        = string
  default     = "cx33"
}

variable "server_image" {
  description = "Server operating system image"
  type        = string
  default     = "debian-13"
}

variable "location" {
  description = "Server location"
  type        = string
  default     = "nbg1"
}

variable "ssh_public_key" {
  description = "Primary SSH public key for server access"
  type        = string
}

variable "ssh_public_key_secondary" {
  description = "Secondary SSH public key"
  type        = string
  default     = ""
}

variable "devops_username" {
  description = "Username for the DevOps account"
  type        = string
  default     = "devops"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

variable "project" {
  description = "Project/group name for DNS (e.g., g2)"
  type        = string
  default     = "g2"
}

variable "dns_zone" {
  description = "DNS zone name (e.g., g2.sdi.hdm-stuttgart.cloud)"
  type        = string
  default     = "g2.sdi.hdm-stuttgart.cloud"
}

variable "dns_secret" {
  description = "HMAC-SHA512 secret for HDM Stuttgart DNS"
  type        = string
  sensitive   = true
}

variable "server_names" {
  description = "List of server hostname prefixes (e.g., ['www', 'mail'])"
  type        = list(string)
  default     = ["www", "mail"]
}

variable "email" {
  description = "Email address for Let's Encrypt registration"
  type        = string
  default     = "admin@example.com"
}

variable "use_production" {
  description = "Use production Let's Encrypt server (false = staging)"
  type        = bool
  default     = false
}

variable "existing_ssh_key_name" {
  description = "Reuse existing primary SSH key by name (skips creation)"
  type        = string
  default     = ""
}

variable "existing_ssh_key_secondary_name" {
  description = "Reuse existing secondary SSH key by name (skips creation)"
  type        = string
  default     = ""
}
