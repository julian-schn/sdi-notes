variable "dns_zone" {
  description = "The DNS zone name (e.g., g2.sdi.hdm-stuttgart.cloud)"
  type        = string
}

variable "project" {
  description = "Project/group name for DNS key (e.g., g2)"
  type        = string
}

variable "dns_secret" {
  description = "HMAC-SHA512 secret for HDM Stuttgart DNS"
  type        = string
  sensitive   = true
}

variable "server_ip" {
  description = "The IP address the records should resolve to"
  type        = string
  default     = "1.2.3.4"
}

variable "server_name" {
  description = "The canonical name of the server (A record)"
  type        = string
  default     = "workhorse"
}

variable "server_aliases" {
  description = "List of alias names for the server (CNAME records)"
  type        = list(string)
  default     = ["www", "mail"]

  validation {
    condition     = length(distinct(var.server_aliases)) == length(var.server_aliases)
    error_message = "Duplicate server alias names found. Each alias must be unique."
  }
}

variable "existing_ssh_key_name" {
  description = "Existing primary SSH key name (unused in this exercise)"
  type        = string
  default     = ""
}
