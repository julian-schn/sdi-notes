# 18 - SSH Module Refactor

> **Working Code:** [`terraform/exercise-18-ssh-module/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-18-ssh-module/)

**The Problem:** In Exercise 16, we wrote a lot of boilerplate (wrapper scripts, known_hosts logic). Copy-pasting that for every project is a nightmare.

**The Solution:** Encapsulate that logic into a reusable Terraform Module.

## Objective
Move the `null_resource` and `local_file` resources from Exercise 16 into a shared module: `modules/SshKnownHosts`.

## How-to

### 1. Create the Module
Move the logic into `modules/SshKnownHosts/main.tf`. The module should take `server_ip` and `devops_username` as inputs.

### 2. Use the Module
Now your main code is clean. Just call the module:

```hcl
module "ssh_known_hosts" {
  source = "../modules/SshKnownHosts"

  server_ip       = hcloud_server.web.ipv4_address
  devops_username = var.devops_user
}
```

### 3. Expose Outputs
If you want to know where the script lives, output it from the module:

```hcl
output "ssh_connect_cmd" {
  value = module.ssh_known_hosts.ssh_wrapper_path
}
```

## Verification
1. `terraform apply`
2. Check `bin/`: You should see the wrapper script.
3. Use it: `./bin/ssh` -> Success.

## Related Exercises
- [24 - Multiple Servers](./24-multiple-servers.md) - Using this module with `count` loops
