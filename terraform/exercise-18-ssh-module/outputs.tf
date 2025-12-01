# Outputs for Exercise 18 - SSH Module Refactor

output "server_name" {
  description = "Name of the created server"
  value       = hcloud_server.main_server.name
}

output "server_ip" {
  description = "Public IPv4 address of the server"
  value       = hcloud_server.main_server.ipv4_address
}

output "nginx_url" {
  description = "URL to access Nginx web server"
  value       = "http://${hcloud_server.main_server.ipv4_address}"
}

output "ssh_wrapper_path" {
  description = "Path to the generated SSH wrapper script"
  value       = module.ssh_known_hosts.ssh_wrapper_path
}

output "scp_wrapper_path" {
  description = "Path to the generated SCP wrapper script"
  value       = module.ssh_known_hosts.scp_wrapper_path
}
