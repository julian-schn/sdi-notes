# Outputs for Exercise 23 - DNS Host

output "server_ip" {
  description = "Public IPv4 address of the server"
  value       = hcloud_server.main_server.ipv4_address
}

output "server_fqdn" {
  description = "Fully qualified domain name of the server"
  value       = local.server_fqdn
}

output "ssh_command" {
  description = "SSH command using the wrapper script"
  value       = "./bin/ssh"
}

output "ssh_direct_command" {
  description = "Direct SSH command using hostname"
  value       = "ssh -o UserKnownHostsFile=gen/known_hosts ${var.devops_username}@${local.server_fqdn}"
}

output "web_url" {
  description = "URL to access the web server"
  value       = "http://${local.server_fqdn}"
}
