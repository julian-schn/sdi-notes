# Secrets Management for Terraform

This document covers different approaches to managing secrets in your Terraform configuration, from simple `.env` files to enterprise-grade encryption with SOPS.

## Table of Contents

1. [Quick Start: .env File (Current)](#quick-start-env-file-current)
2. [SOPS Encryption (Advanced)](#sops-encryption-advanced)
3. [Comparison](#comparison)
4. [Best Practices](#best-practices)

---

## Quick Start: .env File (Current)

**Status:** ✅ **Currently Implemented**

This is the simplest and recommended approach for learning and development.

### Setup

1. **Copy the example file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` with your values:**
   ```bash
   nano .env
   ```

3. **Source the file before using Terraform:**
   ```bash
   source .env
   terraform plan
   ```

### Advantages

✅ Simple and easy to understand
✅ Works immediately without additional tools
✅ Good for development and learning
✅ Terraform automatically reads `TF_VAR_*` environment variables

### Disadvantages

❌ Secrets stored in plaintext
❌ Easy to accidentally commit (must rely on `.gitignore`)
❌ No audit trail of who accessed secrets
❌ Not suitable for production or team environments

### Security Notes

- **Always** keep `.env` in `.gitignore`
- Never commit `.env` to version control
- Use different `.env` files for different environments
- Regularly rotate your API tokens

---

## SOPS Encryption (Advanced)

**Status:** 📝 **Documented for Future Use**

[Mozilla SOPS](https://github.com/mozilla/sops) (Secrets OPerationS) encrypts your secrets at rest while keeping files in version control. Good for teams and production.

### Why SOPS?

✅ Secrets encrypted in git
✅ Team members can decrypt with their own keys
✅ Audit trail via git history
✅ Works with age, PGP, AWS KMS, GCP KMS, Azure Key Vault
✅ Only encrypts values, not keys (readable diffs)

### Prerequisites

Install required tools:

```bash
# Install SOPS
# macOS
brew install sops

# Linux
wget https://github.com/mozilla/sops/releases/download/v3.8.1/sops-v3.8.1.linux.amd64
sudo mv sops-v3.8.1.linux.amd64 /usr/local/bin/sops
sudo chmod +x /usr/local/bin/sops

# Install age (simpler than PGP)
# macOS
brew install age

# Linux
sudo apt install age  # or download from github.com/FiloSottile/age
```

### Setup with age

1. **Generate an age key:**
   ```bash
   mkdir -p ~/.config/sops/age
   age-keygen -o ~/.config/sops/age/keys.txt

   # Save the public key output, looks like:
   # Public key: age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
   ```

2. **Create SOPS configuration:**
   ```bash
   # Create .sops.yaml in repo root
   cat > .sops.yaml << 'EOF'
   creation_rules:
     - path_regex: \.enc\.env$
       age: age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
   EOF
   ```

3. **Create encrypted .env file:**
   ```bash
   # Copy your plain .env
   cp terraform/.env terraform/.env.plain

   # Encrypt it
   sops --encrypt terraform/.env.plain > terraform/.env.enc

   # Delete plaintext
   rm terraform/.env.plain
   ```

4. **Edit encrypted file:**
   ```bash
   # SOPS automatically decrypts in your editor
   sops terraform/.env.enc
   ```

5. **Use with Terraform:**
   ```bash
   # Decrypt and source in one command
   eval "$(sops -d terraform/.env.enc)"

   # Or create a helper script
   cat > terraform/decrypt-env.sh << 'EOF'
   #!/bin/bash
   # Decrypt and export environment variables
   eval "$(sops -d "$(dirname "$0")/.env.enc")"
   EOF
   chmod +x terraform/decrypt-env.sh

   # Usage:
   source terraform/decrypt-env.sh
   terraform plan
   ```

### Alternative: Encrypted terraform.tfvars

Instead of `.env`, you can encrypt `terraform.tfvars`:

```bash
# Create encrypted tfvars
sops terraform.tfvars.enc

# Add your secrets (SOPS opens editor)
# When saved, file is encrypted

# Use with Terraform
sops exec-file terraform.tfvars.enc 'terraform plan -var-file={}'
```

### Team Setup

For multiple team members:

1. **Each team member generates a key:**
   ```bash
   age-keygen -o ~/.config/sops/age/keys.txt
   # Share public key with team
   ```

2. **Update `.sops.yaml` with all public keys:**
   ```yaml
   creation_rules:
     - path_regex: \.enc\.env$
       age: >-
         age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p,
         age1zvkyg2lqzraa2lnjvqej32nkuu0ues2s82hzrye869xeexvn73equnujwj,
         age1...
   ```

3. **Re-encrypt existing files (adds new recipients):**
   ```bash
   sops updatekeys terraform/.env.enc
   ```

### Alternative: Using AWS KMS

For production with AWS:

```yaml
# .sops.yaml
creation_rules:
  - path_regex: \.enc\.(env|tfvars)$
    kms: arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012
    aws_profile: production
```

### Git Ignore Configuration

```bash
# Add to .gitignore
.env
.env.local
*.env.plain
terraform.tfvars
!*.enc  # Allow encrypted files

# Commit encrypted files
git add terraform/.env.enc
git add .sops.yaml
git commit -m "Add encrypted environment variables"
```

---

## Comparison

| Feature | .env File | SOPS + age | SOPS + KMS |
|---------|-----------|------------|------------|
| **Complexity** | Simple | Medium | High |
| **Setup Time** | 1 min | 5 min | 15 min |
| **Team Sharing** | Manual | Easy | Easy |
| **In Git** | ❌ No | ✅ Yes (encrypted) | ✅ Yes (encrypted) |
| **Audit Trail** | ❌ No | ✅ Yes (via git) | ✅ Yes (KMS + git) |
| **Access Control** | File system | Key-based | IAM roles |
| **Cloud Integration** | ❌ No | ❌ No | ✅ Yes |
| **Cost** | Free | Free | AWS charges |
| **Best For** | Learning, solo dev | Teams, most projects | Enterprise, production |

---

## Best Practices

### General

1. **Never commit plaintext secrets**
2. **Use different secrets per environment** (dev, staging, prod)
3. **Rotate credentials regularly**
4. **Use minimal permissions** (principle of least privilege)
5. **Document who has access** to secrets

### For .env (Current Setup)

```bash
# Good practices
✅ Keep .env in .gitignore
✅ Use .env.example as template
✅ Document required variables
✅ Use different .env per environment

# Bad practices
❌ Committing .env to git
❌ Sharing .env via chat/email
❌ Reusing same secrets across environments
❌ Using production secrets in development
```

### For SOPS

```bash
# Good practices
✅ Commit .sops.yaml
✅ Commit encrypted files (*.enc)
✅ Keep private keys secure (~/.config/sops/age/keys.txt)
✅ Back up private keys securely
✅ Update keys when team members leave

# Bad practices
❌ Committing private keys
❌ Sharing private keys via insecure channels
❌ Using same key for all environments
❌ Not backing up keys
```

---

## Migration Path

### From .env to SOPS

When you're ready to upgrade to SOPS:

1. **Install SOPS and age**
2. **Generate keys**
3. **Create `.sops.yaml`**
4. **Encrypt current `.env`:**
   ```bash
   sops --encrypt .env > .env.enc
   rm .env  # Remove plaintext
   ```
5. **Update CI/CD** to use `sops -d`
6. **Update team documentation**
7. **Share public keys** with team
8. **Commit encrypted files:**
   ```bash
   git add .sops.yaml .env.enc
   git commit -m "Migrate to SOPS encryption"
   ```

### Testing SOPS Setup

```bash
# Test encryption
echo "TEST_VAR=secret123" > test.env
sops --encrypt test.env > test.env.enc

# Test decryption
sops --decrypt test.env.enc

# Test with Terraform
eval "$(sops -d test.env.enc)"
echo $TEST_VAR  # Should print: secret123

# Cleanup
rm test.env test.env.enc
```

---

## Troubleshooting

### SOPS Issues

**Error: "no key could decrypt the data"**
```bash
# Check your age key is configured
ls ~/.config/sops/age/keys.txt

# Check SOPS_AGE_KEY_FILE is set or use default location
export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt
```

**Error: "failed to get data key"**
```bash
# Your public key might not be in .sops.yaml
cat .sops.yaml
# Compare with your public key
age-keygen -y ~/.config/sops/age/keys.txt
```

### .env Issues

**Variables not loaded**
```bash
# Make sure you sourced the file
source .env

# Check variables are exported
env | grep TF_VAR

# Verify HCLOUD_TOKEN
echo $HCLOUD_TOKEN
```

---

## Additional Resources

### SOPS
- [Official Documentation](https://github.com/mozilla/sops)
- [age encryption](https://github.com/FiloSottile/age)
- [SOPS with Terraform](https://blog.gruntwork.io/a-comprehensive-guide-to-managing-secrets-in-your-terraform-code-1d586955ace1)

### Terraform Secrets
- [Sensitive Variables](https://www.terraform.io/language/values/variables#suppressing-values-in-cli-output)
- [Environment Variables](https://www.terraform.io/cli/config/environment-variables)

### Alternative Tools
- [Vault by HashiCorp](https://www.vaultproject.io/) - Full secrets management platform
- [git-crypt](https://github.com/AGWA/git-crypt) - Transparent git encryption
- [BlackBox](https://github.com/StackExchange/blackbox) - Store secrets in VCS

---

## Summary

**For this course:** Stick with `.env` files - they're simple and effective for learning.

**For production projects:** Consider SOPS when:
- Working in a team
- Need audit trail
- Want secrets in version control (encrypted)
- Require compliance/security standards

**For enterprise:** Look at SOPS + KMS or HashiCorp Vault for full secrets management.

Remember: **The best security is the security you'll actually use.** Start simple, upgrade when needed!
