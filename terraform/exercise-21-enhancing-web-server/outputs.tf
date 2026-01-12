output "server_ip" {
  value = hcloud_server.web_server.ipv4_address
}

output "domain_root" {
  value = "${var.project}.sdi.hdm-stuttgart.cloud"
}

output "domain_www" {
  value = "www.${var.project}.sdi.hdm-stuttgart.cloud"
}
