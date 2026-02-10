# 16 - Solving the known_hosts Quirk

> **Working Code:** [`terraform/exercise-16-known-hosts/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-16-known-hosts/)

**The Problem:** Every time you recreate a server with the same IP, SSH complains: `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED`.

**The Solution:** Use a project-specific `known_hosts` file and wrapper script. Don't pollute your global `~/.ssh/known_hosts`.

## Objective
Generate `./bin/ssh` that uses a local `known_hosts` file for warning-free connections.

## How-to

### 1. Wrapper Template
```bash
#!/usr/bin/env bash
GEN_DIR=$(dirname "$0")/../gen
ssh -o UserKnownHostsFile="$GEN_DIR/known_hosts" ${devopsUsername}@${ip} "$@"
```

### 2. Terraform Config
```hcl
# Scan host key
resource "null_resource" "known_hosts" {
  triggers = { server_ip = hcloud_server.web.ipv4_address }
  provisioner "local-exec" {
    command = "ssh-keyscan ${hcloud_server.web.ipv4_address} > gen/known_hosts"
  }
}

# Create wrapper
resource "local_file" "ssh_script" {
  content = templatefile("tpl/ssh.sh", {
    ip = hcloud_server.web.ipv4_address
    devopsUsername = var.devops_user
  })
  filename = "bin/ssh"
  file_permission = "0755"
}
```

## Usage
```bash
./bin/ssh  # No warnings, even after 100 recreates
```

## Related Exercises
- [18 - SSH Module](./18-ssh-module.md)
