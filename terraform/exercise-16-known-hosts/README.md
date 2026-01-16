# Exercise 16 - Solving the known_hosts Quirk

This exercise solves a common problem: managing SSH `known_hosts` entries when you frequently create and destroy servers. Instead of polluting your global `~/.ssh/known_hosts` file, we generate deployment-specific known_hosts and wrapper scripts.

## The Problem

When you SSH to a new server, SSH asks you to verify the host key:

```
The authenticity of host '123.45.67.89 (123.45.67.89)' can't be established.
ED25519 key fingerprint is SHA256:...
Are you sure you want to continue connecting (yes/no)?
```

This adds an entry to `~/.ssh/known_hosts`. When you destroy and recreate servers with the same IP, you get errors:

```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
```

## The Solution

Generate **deployment-specific** known_hosts and wrapper scripts:

1. **`gen/known_hosts`** - Contains only the current server's host key
2. **`bin/ssh`** - SSH wrapper that uses the deployment-specific known_hosts
3. **`bin/scp`** - SCP wrapper that uses the deployment-specific known_hosts

These are regenerated on every `terraform apply`, so they always match your current infrastructure.

## What's New in Exercise 16

- **`null_resource` with `local-exec`** - Runs `ssh-keyscan` to fetch host keys
- **`local_file` resources** - Generate executable wrapper scripts from templates
- **Template files** - `tpl/ssh.sh` and `tpl/scp.sh` templates
- **Generated artifacts** - `gen/known_hosts`, `bin/ssh`, `bin/scp`

## Prerequisites

- Understanding of Exercises 13-15
- Hetzner Cloud account with API token
- Terraform installed (>= 1.0)
- SSH key pair

## Usage

1. **Copy the example variables file:**

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars`:**

   ```hcl
   ssh_public_key = file("~/.ssh/id_ed25519.pub")
   devops_username = "devops"
   ```

3. **Set your Hetzner API token:**

   ```bash
   export HCLOUD_TOKEN="replace-me"
   ```

4. **Initialize and apply:**

   ```bash
   terraform init
   terraform apply
   ```

5. **Wait for cloud-init to complete** (2-3 minutes)

6. **Use the wrapper scripts:**

   ```bash
   # Connect via SSH
   ./bin/ssh

   # Copy file TO server
   ./bin/scp file.txt devops@<ip>:/tmp/

   # Copy file FROM server
   ./bin/scp devops@<ip>:/tmp/file.txt ./

   # Run remote commands
   ./bin/ssh "uname -a"
   ```

## How It Works

### 1. Generate known_hosts

The `null_resource.known_hosts` runs `ssh-keyscan` to fetch the server's host key:

```hcl
provisioner "local-exec" {
  command = <<-EOT
    mkdir -p "${path.module}/gen"
    ssh-keyscan -t ed25519 ${server_ip} > "${path.module}/gen/known_hosts"
  EOT
}
```

This creates `gen/known_hosts` with just one entry for your server.

### 2. Generate SSH Wrapper

The `local_file.ssh_wrapper` renders `tpl/ssh.sh` with your server's IP:

```bash
#!/usr/bin/env bash
GEN_DIR=$(dirname "$0")/../gen
ssh -o UserKnownHostsFile="$GEN_DIR/known_hosts" devops@123.45.67.89 "$@"
```

The `-o UserKnownHostsFile=` option tells SSH to use our deployment-specific file instead of `~/.ssh/known_hosts`.

### 3. Generate SCP Wrapper

Similar to SSH wrapper, but for file transfers.

## Verification

### 1. Check Generated Files

```bash
# Known hosts file
cat gen/known_hosts
# Should show: 123.45.67.89 ssh-ed25519 AAAA...

# SSH wrapper
cat bin/ssh
# Should be an executable script

# Check permissions
ls -l bin/
# Should show: -rwxr-xr-x (0755)
```

### 2. Test SSH Wrapper

```bash
./bin/ssh
# Should connect without any host verification prompt!

# Run a command
./bin/ssh "hostname"
```

### 3. Test SCP Wrapper

```bash
# Create a test file
echo "Hello from Exercise 16" > test.txt

# Upload it
./bin/scp test.txt devops@$(terraform output -raw server_ip):/tmp/

# Verify
./bin/ssh "cat /tmp/test.txt"
```

### 4. Your Global known_hosts is Clean

```bash
# This should NOT show your server's IP
grep $(terraform output -raw server_ip) ~/.ssh/known_hosts
# (should return nothing)
```

## Benefits

✅ **No global known_hosts pollution** - Each deployment is isolated
✅ **No manual cleanup** - Destroy and recreate without errors
✅ **Team-friendly** - Everyone uses the same wrapper scripts
✅ **CI/CD ready** - Scripts are generated automatically
✅ **No host verification prompts** - Scripts work immediately

## Troubleshooting

**ssh-keyscan fails?**

- Server might not be ready yet
- Check: `ssh-keyscan $(terraform output -raw server_ip)`
- Wait a few seconds and `terraform apply` again

**Wrapper scripts have wrong IP?**

- Destroy and recreate: `terraform apply -replace=hcloud_server.main_server`

**Permission denied on wrapper scripts?**

```bash
chmod +x bin/ssh bin/scp
```

**Need to pass additional SSH options?**

```bash
./bin/ssh -v  # verbose mode
./bin/ssh -L 8080:localhost:80  # port forwarding
```

## Advanced Usage

### Custom SSH Options

Edit the wrapper scripts to add default options:

```bash
ssh -o UserKnownHostsFile="$GEN_DIR/known_hosts" \
    -o StrictHostKeyChecking=yes \
    -o ConnectTimeout=10 \
    ${devopsUsername}@${ip} "$@"
```

### Use in Scripts

```bash
#!/bin/bash
cd terraform/exercise-16-known-hosts
./bin/ssh "sudo systemctl status nginx"
./bin/scp /path/to/config.txt devops@server:/etc/app/
./bin/ssh "sudo systemctl restart app"
```

## Next Steps

- **Exercise 17**: Generate host metadata using Terraform modules

## Cleanup

```bash
terraform destroy
```

This will also remove the generated `bin/` and `gen/` directories.

## Learn More

- [SSH known_hosts format](https://man.openbsd.org/sshd.8#SSH_KNOWN_HOSTS_FILE_FORMAT)
- [ssh-keyscan documentation](https://man.openbsd.org/ssh-keyscan)
- [Terraform null_resource](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource)
- [Terraform local_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file)
