# Output values for the created resources
output "server_id" {
  description = "ID of the created server"
  value       = hcloud_server.main_server.id
}

output "server_name" {
  description = "Name of the created server"
  value       = hcloud_server.main_server.name
}

output "server_public_ipv4" {
  description = "Public IPv4 address of the server"
  value       = hcloud_server.main_server.ipv4_address
}

output "server_public_ipv6" {
  description = "Public IPv6 address of the server"
  value       = hcloud_server.main_server.ipv6_address
}

output "server_status" {
  description = "Status of the server"
  value       = hcloud_server.main_server.status
}

output "server_location" {
  description = "Location where the server is deployed"
  value       = hcloud_server.main_server.location
}

output "ssh_connection" {
  description = "SSH connection command"
  value       = "ssh root@${hcloud_server.main_server.ipv4_address}"
}

output "firewall_id" {
  description = "ID of the created firewall"
  value       = hcloud_firewall.server_firewall.id
}

output "ssh_key_primary_id" {
  description = "ID of the primary SSH key"
  value       = hcloud_ssh_key.primary.id
}

output "ssh_key_secondary_id" {
  description = "ID of the secondary SSH key (if created)"
  value       = var.ssh_public_key_secondary != "" ? hcloud_ssh_key.secondary[0].id : null
}

output "ssh_keys_deployed" {
  description = "List of SSH key IDs deployed to the server"
  value = concat(
    [hcloud_ssh_key.primary.id],
    var.ssh_public_key_secondary != "" ? [hcloud_ssh_key.secondary[0].id] : []
  )
}
