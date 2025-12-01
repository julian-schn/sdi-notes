# Outputs for Exercise 15 - Cloud-init Server

output "server_ip" {
  description = "Public IPv4 address of the server"
  value       = hcloud_server.main_server.ipv4_address
}

output "server_ipv6" {
  description = "Public IPv6 address of the server"
  value       = hcloud_server.main_server.ipv6_address
}

output "nginx_url" {
  description = "URL to access Nginx web server"
  value       = "http://${hcloud_server.main_server.ipv4_address}"
}

output "ssh_command" {
  description = "SSH command to access the server as devops user"
  value       = "ssh ${var.devops_username}@${hcloud_server.main_server.ipv4_address}"
}

output "server_datacenter" {
  description = "Datacenter where the server is located"
  value       = hcloud_server.main_server.datacenter
}

output "server_status" {
  description = "Current status of the server"
  value       = hcloud_server.main_server.status
}
