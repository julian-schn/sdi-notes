# 16 - Solving the ~/.ssh/known_hosts Quirk

> **Working Code:** [`terraform/exercise-16-known-hosts/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-16-known-hosts/)

## Overview
Generate per-deployment SSH known_hosts and wrapper scripts so `ssh`/`scp` work without global known_hosts prompts. This approach isolates server host keys per project, preventing conflicts when recreating servers.

## Prerequisites
- Completed [Exercise 15 - Cloud Init](./15-cloud-init.md)
- Understanding of SSH host key verification
- Familiarity with Terraform templating

## Objective
Terraform fetches the server's SSH host key and writes it to `terraform/gen/known_hosts`. Terraform renders `terraform/bin/ssh` and `terraform/bin/scp` from templates, pointing them at that file. You run `./terraform/bin/ssh` or `./terraform/bin/scp` and never touch your global `~/.ssh/known_hosts`.

## Implementation

### Step 1: Add SSH and SCP Wrapper Templates
Create template files (Terraform module-relative):

```bash
# tpl/ssh.sh
#!/usr/bin/env bash
GEN_DIR=$(dirname "$0")/../gen
ssh -o UserKnownHostsFile="$GEN_DIR/known_hosts" ${devopsUsername}@${ip} "$@"

# tpl/scp.sh
#!/usr/bin/env bash
GEN_DIR=$(dirname "$0")/../gen
if [ $# -lt 2 ]; then
   echo "usage: .../bin/scp ... ${devopsUsername}@${ip} ..."
else
   scp -o UserKnownHostsFile="$GEN_DIR/known_hosts" "$@"
fi
```

### Step 2: Generate Wrappers with Terraform
Add Terraform resources to generate the wrapper scripts:

```hcl
resource "local_file" "ssh_wrapper" {
  content = templatefile("${path.module}/tpl/ssh.sh", {
    devopsUsername = var.devops_username
    ip             = hcloud_server.main_server.ipv4_address
  })
  filename        = "${path.module}/bin/ssh"
  file_permission = "0755"
}

resource "local_file" "scp_wrapper" {
  content = templatefile("${path.module}/tpl/scp.sh", {
    devopsUsername = var.devops_username
    ip             = hcloud_server.main_server.ipv4_address
  })
  filename        = "${path.module}/bin/scp"
  file_permission = "0755"
}
```

### Step 3: Create Deployment-Scoped known_hosts
Use ssh-keyscan to fetch and store the server's host key:

```hcl
resource "null_resource" "known_hosts" {
  depends_on = [hcloud_server.main_server]
  triggers = { server_ip = hcloud_server.main_server.ipv4_address }
  provisioner "local-exec" {
    command = <<EOT
      set -euo pipefail
      mkdir -p "${path.module}/gen"
      ssh-keyscan -t ed25519 ${hcloud_server.main_server.ipv4_address} > "${path.module}/gen/known_hosts"
    EOT
  }
}
```

### Step 4: Ignore Generated Artifacts in Git
Add to `.gitignore`:

```
terraform/bin/
terraform/gen/
```

### Step 5: Apply and Use
Apply the configuration:

```bash
terraform apply
```

Connect using the generated wrappers:
```bash
./terraform/bin/ssh
```

Transfer files:
```bash
./terraform/bin/scp localfile.txt :~/
```

## Verification
1. Apply Terraform: `terraform apply`
2. Check generated files exist: `ls terraform/bin/ssh terraform/gen/known_hosts`
3. Connect with wrapper: `./terraform/bin/ssh`
4. Verify no global known_hosts prompt
5. Test scp wrapper: `./terraform/bin/scp /etc/hosts :/tmp/`

## Problems & Learnings

::: warning Common Issues
*This section will be filled in collaboratively. Common issues encountered during this exercise will be documented here.*
:::

::: tip Key Takeaways
*Key learnings and best practices from this exercise will be documented here.*
:::

## Related Exercises
- [15 - Cloud Init](./15-cloud-init.md) - Server bootstrapping
- [18 - SSH Module](./18-ssh-module.md) - Refactoring SSH logic into reusable module
- [23 - Host with DNS](./23-host-with-dns.md) - Using DNS names instead of IP addresses
