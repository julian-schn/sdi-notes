output "server_ip" {
  value = hcloud_server.web_server.ipv4_address
}

output "domain_root" {
  value = "${var.project}.${var.dns_zone}"
}

output "domain_www" {
  value = "www.${var.project}.${var.dns_zone}"
}
