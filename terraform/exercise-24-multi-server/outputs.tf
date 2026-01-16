# Outputs for Exercise 24 - Multi-Server

output "server_names" {
  description = "Names of the created servers"
  value       = local.server_names
}

output "server_ips" {
  description = "Public IPv4 addresses of all servers"
  value       = { for i, server in hcloud_server.servers : local.server_names[i] => server.ipv4_address }
}

output "server_fqdns" {
  description = "Fully qualified domain names of all servers"
  value       = [for name in local.server_names : "${name}.${var.dns_zone}"]
}

output "ssh_commands" {
  description = "SSH commands for each server"
  value       = { for name in local.server_names : name => "./${name}/bin/ssh" }
}

output "ssh_direct_commands" {
  description = "Direct SSH commands for each server"
  value       = { for name in local.server_names : name => "ssh -o UserKnownHostsFile=${name}/gen/known_hosts ${var.devops_username}@${name}.${var.dns_zone}" }
}

output "web_urls" {
  description = "URLs to access each web server"
  value       = { for name in local.server_names : name => "http://${name}.${var.dns_zone}" }
}
