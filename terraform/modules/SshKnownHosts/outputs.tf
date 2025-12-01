output "ssh_wrapper_path" {
  description = "Path to the generated SSH wrapper script"
  value       = local_file.ssh_wrapper.filename
}

output "scp_wrapper_path" {
  description = "Path to the generated SCP wrapper script"
  value       = local_file.scp_wrapper.filename
}
