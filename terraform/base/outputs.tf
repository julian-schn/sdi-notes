# Outputs for Exercise 13 - Base System

output "server_ip" {
  description = "Public IPv4 address of the server"
  value       = hcloud_server.hello_server.ipv4_address
}

output "server_ipv6" {
  description = "Public IPv6 address of the server"
  value       = hcloud_server.hello_server.ipv6_address
}

output "server_location" {
  description = "Location where the server is located"
  value       = hcloud_server.hello_server.location
}

output "server_status" {
  description = "Current status of the server"
  value       = hcloud_server.hello_server.status
}
