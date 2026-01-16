# Outputs for Exercise 17 - Host Metadata

output "server_name" {
  description = "Name of the created server"
  value       = hcloud_server.main_server.name
}

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

output "ssh_wrapper_path" {
  description = "Path to the generated SSH wrapper script"
  value       = "${path.module}/bin/ssh"
}

output "scp_wrapper_path" {
  description = "Path to the generated SCP wrapper script"
  value       = "${path.module}/bin/scp"
}

output "metadata_file_path" {
  description = "Path to the generated metadata JSON file"
  value       = module.host_metadata.filename
}

output "server_location" {
  description = "Location where the server is located"
  value       = hcloud_server.main_server.location
}

output "server_status" {
  description = "Current status of the server"
  value       = hcloud_server.main_server.status
}
