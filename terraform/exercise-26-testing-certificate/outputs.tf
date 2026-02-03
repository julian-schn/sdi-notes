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

output "ssh_connection" {
  description = "SSH connection command"
  value       = "ssh -o UserKnownHostsFile=${path.module}/gen/known_hosts ${var.devops_username}@${var.dns_zone}"
}

output "certificate_info" {
  description = "Certificate information"
  value = {
    common_name = acme_certificate.wildcard.common_name
    sans        = acme_certificate.wildcard.subject_alternative_names
    issuer_url  = acme_certificate.wildcard.certificate_url
    expires     = acme_certificate.wildcard.min_days_remaining
  }
}

output "acme_server" {
  description = "ACME server used (staging or production)"
  value       = var.use_production ? "production" : "staging"
}

output "test_instructions" {
  description = "Instructions for testing the certificate"
  value       = <<-EOT
    Test your SSL certificate:
    1. Visit https://${var.dns_zone}
    2. Visit ${join(", ", [for name in var.server_names : "https://${name}.${var.dns_zone}"])}
    3. Check the certificate details (should show ${var.dns_zone} and *.${var.dns_zone})

    NOTE: If apex DNS creation failed, you'll need to manually create the A record
    for ${var.dns_zone} or use https://www.${var.dns_zone} instead.

    Using ${var.use_production ? "PRODUCTION" : "STAGING"} certificate.
    Staging certificates will show browser warnings - this is expected!
  EOT
}
