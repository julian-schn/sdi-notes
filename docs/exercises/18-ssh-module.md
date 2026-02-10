# 18 - SSH Module Refactor

> **Working Code:** [`terraform/exercise-18-ssh-module/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-18-ssh-module/)

**The Problem:** Exercise 16's SSH boilerplate (wrappers, known_hosts) gets copy-pasted everywhere.

**The Solution:** Encapsulate into a reusable Terraform module.

## Objective
Move SSH logic from Exercise 16 into `modules/SshKnownHosts`.

## How-to

### 1. Create Module
Move logic into `modules/SshKnownHosts/main.tf` with inputs: `server_ip`, `devops_username`.

### 2. Use Module
```hcl
module "ssh_known_hosts" {
  source = "../modules/SshKnownHosts"

  server_ip       = hcloud_server.web.ipv4_address
  devops_username = var.devops_user
}
```

### 3. Output Paths
```hcl
output "ssh_connect_cmd" {
  value = module.ssh_known_hosts.ssh_wrapper_path
}
```

## Verification
```bash
terraform apply
ls bin/  # See wrapper script
./bin/ssh  # Works!
```

## Related Exercises
- [24 - Multiple Servers](./24-multiple-servers.md)
