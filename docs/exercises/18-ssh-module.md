# 18 - SSH Module Refactor

> **Working Code:** [`terraform/exercise-18-ssh-module/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-18-ssh-module/)

## Overview
Refactor the SSH/SCP wrapper and known_hosts generation logic from Exercise 16 into a reusable module. This demonstrates good Terraform practices by creating modular, reusable infrastructure components.

## Prerequisites
- Completed [Exercise 16 - SSH Known Hosts](./16-ssh-known-hosts.md)
- Understanding of Terraform modules
- Familiarity with module outputs

## Objective
Move the `null_resource` and `local_file` resources from Exercise 16 into a shared module: `modules/SshKnownHosts`. Exercise 18 simply calls this module. The result is cleaner code and reusability.

## Implementation

### Step 1: Create the SshKnownHosts Module
The module encapsulates all SSH wrapper logic:

```hcl
# modules/SshKnownHosts/main.tf
# - Encapsulates ssh-keyscan logic (with retry)
# - Generates bin/ssh and bin/scp wrappers
# - Outputs paths to the generated scripts
```

### Step 2: Use the Module
In your main configuration:

```hcl
module "ssh_known_hosts" {
  source = "../modules/SshKnownHosts"

  server_ip       = hcloud_server.main_server.ipv4_address
  devops_username = var.devops_username
}
```

### Step 3: Expose Module Outputs
The module outputs the wrapper script paths:

```hcl
# In your root module
output "ssh_wrapper" {
  value = module.ssh_known_hosts.ssh_wrapper_path
}

output "scp_wrapper" {
  value = module.ssh_known_hosts.scp_wrapper_path
}
```

## Verification
1. Apply Terraform: `terraform apply`
2. Verify wrappers generated: `ls ./bin/ssh ./bin/scp`
3. Verify known_hosts created: `cat gen/known_hosts`
4. Test SSH wrapper: `./bin/ssh`
5. Verify connection works without global known_hosts prompt

## Problems & Learnings

::: warning Common Issues
*This section will be filled in collaboratively. Common issues encountered during this exercise will be documented here.*
:::

::: tip Key Takeaways
*Key learnings and best practices from this exercise will be documented here.*
:::

## Related Exercises
- [16 - SSH Known Hosts](./16-ssh-known-hosts.md) - Original implementation before refactoring
- [17 - Host Metadata](./17-host-metadata.md) - Module creation patterns
- [23 - Host with DNS](./23-host-with-dns.md) - Using this module with DNS names
