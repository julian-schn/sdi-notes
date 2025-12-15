output "canonical_domain" {
  value = "${var.server_name}.${var.dns_zone}"
}

output "root_domain" {
  value = var.dns_zone
}

output "alias_domains" {
  value = [for alias in var.server_aliases : "${alias}.${var.dns_zone}"]
}
