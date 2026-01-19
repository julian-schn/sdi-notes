# 18 - SSH Module Refactor

> **Working Code:** [`terraform/exercise-18-ssh-module/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-18-ssh-module/)

- Goal: Refactor the SSH/SCP wrapper and known_hosts generation logic into a reusable module.

TLDR:
- We moved the `null_resource` and `local_file` resources from Exercise 16 into a shared module: `modules/SshKnownHosts`.
- Exercise 18 simply calls this module.
- The result is cleaner code and reusability.

1) **The Module** (`modules/SshKnownHosts`):
   - Encapsulates `ssh-keyscan` logic (with retry).
   - Generates `bin/ssh` and `bin/scp` wrappers.
   - Outputs paths to the generated scripts.

2) **Using the Module**:
```hcl
module "ssh_known_hosts" {
  source = "../modules/SshKnownHosts"

  server_ip       = hcloud_server.main_server.ipv4_address
  devops_username = var.devops_username
}
```

3) **Outputs**:
   - We expose the wrapper paths from the module outputs.

4) **Verify**:
   - `terraform apply`
   - `./bin/ssh` should work exactly as before.
   - `gen/known_hosts` should be created.
