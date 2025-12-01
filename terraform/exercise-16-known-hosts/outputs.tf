# Outputs for Exercise 16 - Known Hosts Solution

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

output "known_hosts_path" {
  description = "Path to the generated known_hosts file"
  value       = "${path.module}/gen/known_hosts"
}

output "usage_instructions" {
  description = "How to use the wrapper scripts"
  value       = <<-EOT
    Connect to server:
      ./bin/ssh

    Copy files to server:
      ./bin/scp localfile.txt ${var.devops_username}@${hcloud_server.main_server.ipv4_address}:/tmp/

    Copy files from server:
      ./bin/scp ${var.devops_username}@${hcloud_server.main_server.ipv4_address}:/tmp/file.txt ./
  EOT
}
