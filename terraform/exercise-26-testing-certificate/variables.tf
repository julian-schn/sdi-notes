# Variables for Exercise 26 - Testing Certificate

variable "server_type" {
  description = "Server type/size"
  type        = string
  default     = "cx23"
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
  description = "Secondary SSH public key for server access (optional)"
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

variable "certificate_path" {
  description = "Path to certificate.pem from Exercise 25"
  type        = string
  default     = "../exercise-25-web-certificate/gen/certificate.pem"
}

variable "private_key_path" {
  description = "Path to private.pem from Exercise 25"
  type        = string
  default     = "../exercise-25-web-certificate/gen/private.pem"
}
