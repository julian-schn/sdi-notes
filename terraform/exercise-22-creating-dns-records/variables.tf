variable "dns_zone" {
  description = "The DNS zone name to add records to"
  type        = string
  default     = "g02.sdi.hdm-stuttgart.cloud" 
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
    error_message = "Duplicate server alias names found."
  }

  validation {
    condition     = !contains(var.server_aliases, var.server_name)
    error_message = "Server alias name matches server's common name."
  }
}
