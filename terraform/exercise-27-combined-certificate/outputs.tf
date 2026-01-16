# Outputs for Exercise 27 - Combined Certificate

output "server_ip" {
  description = "Public IPv4 address"
  value       = hcloud_server.web_server.ipv4_address
}

output "certificate_domains" {
  description = "Domains covered by the certificate"
  value       = [var.dns_zone, "*.${var.dns_zone}"]
}

output "apex_url" {
  description = "HTTPS URL for apex domain"
  value       = "https://${var.dns_zone}"
}

output "server_urls" {
  description = "HTTPS URLs for all server names"
  value       = [for name in var.server_names : "https://${name}.${var.dns_zone}"]
}

output "ssh_command" {
  description = "SSH command"
  value       = "./bin/ssh"
}

output "certificate_path" {
  description = "Local path to certificate"
  value       = local_file.certificate.filename
}

output "private_key_path" {
  description = "Local path to private key"
  value       = local_file.private_key.filename
}

output "is_staging" {
  description = "Whether using staging certificate"
  value       = !var.use_production
}
