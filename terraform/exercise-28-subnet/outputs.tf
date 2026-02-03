# Exercise 28 - Outputs

# ============================================================================
# NETWORK OUTPUTS
# ============================================================================

output "network_id" {
  description = "Private network ID"
  value       = hcloud_network.private_net.id
}

output "network_ip_range" {
  description = "Private network IP range"
  value       = hcloud_network.private_net.ip_range
}

output "subnet_ip_range" {
  description = "Private subnet IP range"
  value       = hcloud_network_subnet.private_subnet.ip_range
}

# ============================================================================
# GATEWAY SERVER OUTPUTS
# ============================================================================

output "gateway_name" {
  description = "Gateway server name"
  value       = hcloud_server.gateway.name
}

output "gateway_ipv4_address" {
  description = "Gateway server public IPv4 address"
  value       = hcloud_server.gateway.ipv4_address
}

output "gateway_ipv6_address" {
  description = "Gateway server public IPv6 address"
  value       = hcloud_server.gateway.ipv6_address
}

output "gateway_private_ip" {
  description = "Gateway server private IP address"
  value       = var.gateway_private_ip
}

output "gateway_status" {
  description = "Gateway server status"
  value       = hcloud_server.gateway.status
}

# ============================================================================
# INTERNAL SERVER OUTPUTS
# ============================================================================

output "intern_name" {
  description = "Internal server name"
  value       = hcloud_server.intern.name
}

output "intern_private_ip" {
  description = "Internal server private IP address"
  value       = var.intern_private_ip
}

output "intern_status" {
  description = "Internal server status"
  value       = hcloud_server.intern.status
}

# ============================================================================
# CONNECTION INFORMATION
# ============================================================================

output "ssh_gateway_command" {
  description = "Command to SSH into gateway server"
  value       = "ssh ${var.devops_username}@${hcloud_server.gateway.ipv4_address}"
}

output "ssh_intern_command" {
  description = "Command to SSH into intern server (from gateway)"
  value       = "ssh ${var.devops_username}@intern"
}

output "ssh_hop_command" {
  description = "Command to SSH into intern via gateway using ProxyJump"
  value       = "ssh -J ${var.devops_username}@${hcloud_server.gateway.ipv4_address} ${var.devops_username}@${var.intern_private_ip}"
}

output "connection_info" {
  description = "Complete connection information"
  value = <<-EOT
    Gateway Server:
      Name:       ${hcloud_server.gateway.name}
      Public IP:  ${hcloud_server.gateway.ipv4_address}
      Private IP: ${var.gateway_private_ip}
      SSH:        ssh ${var.devops_username}@${hcloud_server.gateway.ipv4_address}

    Internal Server:
      Name:       ${hcloud_server.intern.name}
      Private IP: ${var.intern_private_ip}
      SSH (from gateway): ssh ${var.devops_username}@intern
      SSH (ProxyJump):    ssh -J ${var.devops_username}@${hcloud_server.gateway.ipv4_address} ${var.devops_username}@${var.intern_private_ip}

    Network:
      Network IP Range: ${hcloud_network.private_net.ip_range}
      Subnet IP Range:  ${hcloud_network_subnet.private_subnet.ip_range}
      DNS Domain:       ${var.private_subnet.dns_domain_name}
  EOT
}

# ============================================================================
# MAKEFILE COMPATIBILITY
# ============================================================================

output "server_ip" {
  description = "Primary server IP (gateway) for Makefile compatibility"
  value       = hcloud_server.gateway.ipv4_address
}

output "devops_username" {
  description = "DevOps username for SSH connections"
  value       = var.devops_username
}
