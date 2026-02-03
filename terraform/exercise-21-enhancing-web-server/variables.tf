# Exercise 21 - Variables

variable "server_name" {
  description = "Name of the web server"
  type        = string
  default     = "web-server"
}

variable "server_image" {
  description = "Server operating system image"
  type        = string
  default     = "debian-11"
}

variable "server_type" {
  description = "Server type/size"
  type        = string
  default     = "cx33"
}

variable "location" {
  description = "Server location"
  type        = string
  default     = "nbg1"
}

variable "ssh_public_key" {
  description = "Primary public SSH key"
  type        = string
}

variable "ssh_public_key_secondary" {
  description = "Secondary public SSH key (optional)"
  type        = string
  default     = ""
}

variable "project" {
  description = "Project/group name (e.g., g02)"
  type        = string
  default     = "g02"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "devops_username" {
  description = "Username for the DevOps account"
  type        = string
  default     = "devops"
}

variable "dns_secret" {
  description = "HMAC-SHA512 secret for HDM Stuttgart DNS (from dnsupdate.sec)"
  type        = string
  sensitive   = true
}

variable "existing_ssh_key_name" {
  description = "Name of existing primary SSH key in Hetzner Cloud to reuse (optional). If provided, no new primary SSH key will be created."
  type        = string
  default     = ""
}

variable "existing_ssh_key_secondary_name" {
  description = "Name of existing secondary SSH key in Hetzner Cloud to reuse (optional). If provided, no new secondary SSH key will be created."
  type        = string
  default     = ""
}
