# Terraform Secrets Management

This guide covers secure handling of sensitive data in Terraform configurations.

## Security Approach

The configuration uses a hybrid approach that separates sensitive and non-sensitive data across different files.

## File-Based Separation

### Non-Sensitive Configuration

The `terraform.tfvars` file contains safe-to-commit values:

```hcl
# terraform.tfvars (committed to Git)
server_base_name = "server"
server_type      = "cx23"
server_image     = "debian-13"
location         = "nbg1"
environment      = "development"
project          = "hello-world"
```

### Sensitive Data

The `.env` file contains secrets and is ignored by Git:

```bash
# .env (ignored by Git)
export HCLOUD_TOKEN="API_TOKEN"
export TF_VAR_ssh_public_key="ADD_YOUR_SSH_KEY"
export TF_VAR_ssh_public_key_secondary=""
```

## Environment Variables

Terraform automatically reads environment variables with the `TF_VAR_` prefix:

```bash
# Maps to variable "ssh_public_key"
export TF_VAR_ssh_public_key="ssh-ed25519 ..."

# Maps to variable "ssh_public_key_secondary"  
export TF_VAR_ssh_public_key_secondary="ssh-rsa ..."
```

Provider credentials use their own environment variables:

```bash
# Hetzner Cloud provider reads this automatically
export HCLOUD_TOKEN="API_TOKEN"
```

## Variable Precedence

Terraform follows this order when resolving variable values:

1. Command line flags: `-var="key=value"`
2. Variable files: `-var-file="terraform.tfvars"`
3. `terraform.tfvars` file (if present)
4. Environment variables: `TF_VAR_name`
5. Variable defaults in `variables.tf`

## Git Configuration

The `.gitignore` file prevents committing sensitive data:

```gitignore
# Terraform sensitive files
*.tfvars
!*.tfvars.example
!terraform.tfvars
.env
.env.local
*.tfstate
*.tfstate.*
.terraform/
```

This configuration:
- Ignores all `.tfvars` files by default
- Allows `terraform.tfvars` (contains only non-sensitive data)
- Allows example files for reference
- Ignores all environment files

## Environment File Template

The `.env.example` file serves as a template:

```bash
# Environment variables for Terraform (SENSITIVE VALUES ONLY)
export HCLOUD_TOKEN="API_TOKEN"
export TF_VAR_ssh_public_key="ssh-ed25519 ..."
export TF_VAR_ssh_public_key_secondary=""
```

## Variable Definitions

Variables requiring sensitive input have no defaults in `variables.tf`:

```hcl
variable "ssh_public_key" {
  description = "Primary SSH public key for server access"
  type        = string
  # No default - must be provided via environment variable
}
```

## Alternative Approaches

### SOPS Encryption

For teams requiring encrypted files in version control:

```bash
# Install SOPS and age
brew install sops age

# Generate encryption key
age-keygen -o ~/.config/sops/age/keys.txt

# Encrypt terraform.tfvars
sops -e -i terraform.tfvars
```

### HashiCorp Vault

For enterprise secret management:

```hcl
data "vault_generic_secret" "hcloud" {
  path = "secret/hetzner"
}

provider "hcloud" {
  token = data.vault_generic_secret.hcloud.data["api_token"]
}
```

### Cloud Secret Stores

Using managed secret services:

```hcl
# AWS Secrets Manager example
data "aws_secretsmanager_secret_version" "hcloud" {
  secret_id = "hetzner-cloud-token"
}

locals {
  hcloud_token = jsondecode(
    data.aws_secretsmanager_secret_version.hcloud.secret_string
  )["token"]
}
```

## Best Practices

### Development Environment

- Use `.env` files for local secrets
- Commit non-sensitive `terraform.tfvars`
- Never commit actual credentials
- Use separate API tokens per environment

### Team Environment

- Share encrypted files with SOPS
- Use centralized secret management systems
- Implement secret rotation policies
- Maintain audit logs of secret access

### Production Environment

- Use managed secret services
- Implement least-privilege access controls
- Enable comprehensive audit logging
- Automate secret rotation processes

## Validation

Before committing changes, verify no secrets are exposed:

```bash
# Check Git status
git status

# Verify .env is ignored
git check-ignore .env

# Search for potential secrets in staged files
git diff --cached | grep -i "token\|key\|password"
```

## Recovery Procedures

If secrets are accidentally committed:

1. Immediately revoke the exposed credentials in Hetzner Cloud console
2. Generate new API tokens and SSH keys
3. Remove secrets from Git history using `git filter-branch`
4. Force push to all remote repositories
5. Update all systems and team members with new credentials
6. Review access logs for any unauthorized usage