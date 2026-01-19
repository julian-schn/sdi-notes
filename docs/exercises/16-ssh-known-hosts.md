# 16 - Solving the ~/.ssh/known_hosts quirk

> **Working Code:** [`terraform/exercise-16-known-hosts/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-16-known-hosts/)

- Goal: generate per-deployment SSH known_hosts and wrapper scripts so `ssh`/`scp` work without global known_hosts prompts.

TLDR:
- Terraform fetches the server’s SSH host key and writes it to `terraform/gen/known_hosts`.
- Terraform renders `terraform/bin/ssh` and `terraform/bin/scp` from templates, pointing them at that file.
- You run `./terraform/bin/ssh` or `./terraform/bin/scp` and never touch your global `~/.ssh/known_hosts`.

1) Add templates (Terraform module-relative):
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
2) Generate wrappers with Terraform:
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
3) Create a deployment-scoped known_hosts:
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
4) Ignore generated artifacts in git:
```
terraform/bin/
terraform/gen/
```
5) Apply and use:
- `terraform apply` (or replace the server) regenerates `bin/ssh`, `bin/scp`, and `gen/known_hosts`.
- Connect with `./terraform/bin/ssh` or transfer with `./terraform/bin/scp` to avoid touching your global `~/.ssh/known_hosts`. 
