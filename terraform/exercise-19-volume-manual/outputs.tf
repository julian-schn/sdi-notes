# Outputs for Exercise 19 - Manual Volumes

output "server_name" {
  description = "Name of the created server"
  value       = hcloud_server.main_server.name
}

output "server_ip" {
  description = "Public IPv4 address of the server"
  value       = hcloud_server.main_server.ipv4_address
}

output "linux_device" {
  description = "Linux device path for the attached volume"
  value       = hcloud_volume.data_volume.linux_device
}

output "ssh_wrapper_path" {
  description = "Path to the generated SSH wrapper script"
  value       = module.ssh_known_hosts.ssh_wrapper_path
}
