# 16 - Solving the ~/.ssh/known_hosts Quirk

> **Working Code:** [`terraform/exercise-16-known-hosts/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-16-known-hosts/)

**The Problem:** Every time you destroy/recreate a server, it gets a new host key. If the IP stays the same, SSH freaks out: `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED` and blocks you.

**The Solution:** Use a project-specific `known_hosts` file and a wrapper script. Don't pollute your global `~/.ssh/known_hosts`.

## Objective
Generate a script `./terraform/bin/ssh` that uses a local `known_hosts` file, so you can connect without warnings.

## How-to

### 1. The Wrapper Template (`tpl/ssh.sh`)
This script tells SSH to use a local known_hosts file instead of your global one:

```bash
#!/usr/bin/env bash
GEN_DIR=$(dirname "$0")/../gen
ssh -o UserKnownHostsFile="$GEN_DIR/known_hosts" ${devopsUsername}@${ip} "$@"
```

### 2. The Terraform Config
We need Terraform to do three things:
1. Create the server.
2. Scan its key and save it to `gen/known_hosts`.
3. Fill in the template and save it to `bin/ssh`.

```hcl
# Scan the key (requires the server to be up!)
resource "null_resource" "known_hosts" {
  triggers = { server_ip = hcloud_server.web.ipv4_address }
  provisioner "local-exec" {
    command = "ssh-keyscan ${hcloud_server.web.ipv4_address} > gen/known_hosts"
  }
}

# Create the wrapper script
resource "local_file" "ssh_script" {
  content = templatefile("tpl/ssh.sh", {
    ip = hcloud_server.web.ipv4_address
    devopsUsername = var.devops_user
  })
  filename = "bin/ssh"
  file_permission = "0755"
}
```

### 3. Usage
Apply, then connect using your new script:

```bash
./terraform/bin/ssh
```

No more warnings, even if you destroy and recreate the server 100 times.

## Related Exercises
- [18 - SSH Module](./18-ssh-module.md) - Wrapping this logic into a module so you don't have to copy-paste it
