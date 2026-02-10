terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

resource "null_resource" "known_hosts" {
  triggers = {
    server_ip = var.server_ip
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      mkdir -p "${path.root}/gen"
      
      echo "Waiting for SSH to be ready on ${var.server_ip}..."
      for i in {1..30}; do
        if ssh-keyscan -t ed25519 -T 5 ${var.server_ip} 2>/dev/null | grep -q "ssh-ed25519"; then
          echo "SSH is ready, capturing host keys..."
          ssh-keyscan -t ed25519 ${var.server_ip} > "${path.root}/gen/known_hosts" 2>/dev/null
          echo "Host keys saved to gen/known_hosts"
          exit 0
        fi
        echo "Attempt $i/30: SSH not ready yet, waiting 5 seconds..."
        sleep 5
      done
      
      echo "ERROR: SSH did not become available after 150 seconds"
      exit 1
    EOT
  }
}

resource "local_file" "ssh_wrapper" {
  content = templatefile("${path.module}/tpl/ssh.sh", {
    devopsUsername = var.devops_username
    ip             = var.server_ip
  })

  filename             = "${path.root}/bin/ssh"
  file_permission      = "0755"
  directory_permission = "0755"
}

resource "local_file" "scp_wrapper" {
  content = templatefile("${path.module}/tpl/scp.sh", {
    devopsUsername = var.devops_username
    ip             = var.server_ip
  })

  filename             = "${path.root}/bin/scp"
  file_permission      = "0755"
  directory_permission = "0755"
}
