variable "hcloud_token" {
  sensitive = true
  default   = ""
}

variable "server_name" {
  default = "web-server"
}

variable "server_image" {
  default = "debian-11"
}

variable "server_type" {
  default = "cx11"
}

variable "location" {
  default = "nbg1"
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
  default = "g02"
}

variable "environment" {
  default = "production"
}

variable "devops_username" {
  default = "devops"
}

variable "dns_zone" {
  description = "The DNS zone name to add records to"
  default     = "sdi.hdm-stuttgart.cloud"
}
