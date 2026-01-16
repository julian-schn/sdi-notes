# Outputs for Exercise 25 - Web Certificate

output "certificate_url" {
  description = "URL of the issued certificate"
  value       = acme_certificate.wildcard.certificate_url
}

output "certificate_domain" {
  description = "Primary domain of the certificate"
  value       = acme_certificate.wildcard.certificate_domain
}

output "certificate_domains" {
  description = "All domains covered by the certificate"
  value       = concat([local.cert_common_name], ["*.${var.dns_zone}"])
}

output "private_key_path" {
  description = "Path to the private key file"
  value       = local_file.private_key.filename
}

output "certificate_path" {
  description = "Path to the certificate file"
  value       = local_file.certificate.filename
}

output "fullchain_path" {
  description = "Path to the full chain certificate file"
  value       = local_file.fullchain.filename
}

output "is_staging" {
  description = "Whether this is a staging (test) certificate"
  value       = !var.use_production
}

output "warning" {
  description = "Important warning about certificate type"
  value       = var.use_production ? "PRODUCTION certificate - rate limits apply!" : "STAGING certificate - browsers will show warnings"
}
