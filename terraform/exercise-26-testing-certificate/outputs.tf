# Outputs for Exercise 26 - Testing Certificate

output "server_ip" {
  description = "Public IPv4 address of the server"
  value       = hcloud_server.web_server.ipv4_address
}

output "apex_url" {
  description = "HTTPS URL for the apex domain"
  value       = "https://${var.dns_zone}"
}

output "server_urls" {
  description = "HTTPS URLs for all server names"
  value       = [for name in var.server_names : "https://${name}.${var.dns_zone}"]
}

output "all_domains" {
  description = "All domains pointing to this server"
  value       = concat([var.dns_zone], [for name in var.server_names : "${name}.${var.dns_zone}"])
}

output "ssh_command" {
  description = "SSH command to access the server"
  value       = "ssh ${var.devops_username}@${var.dns_zone}"
}

output "test_instructions" {
  description = "Instructions for testing the certificate"
  value       = <<-EOT
    Test your SSL certificate:
    1. Visit ${var.dns_zone} in your browser
    2. Check the certificate details
    3. Visit ${join(", ", [for name in var.server_names : "${name}.${var.dns_zone}"])}
    
    If using staging certificate, you'll see browser warnings - this is expected!
  EOT
}
