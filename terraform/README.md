# Terraform Infrastructure as Code

This directory contains incremental Terraform exercises for learning infrastructure automation with Hetzner Cloud.

## Repository Structure

```
terraform/
├── base/                          # Exercise 13 - Minimal base system
├── exercise-14-nginx/             # Exercise 14 - Nginx automation
├── exercise-15-cloud-init/        # Exercise 15 - Cloud-init configuration
├── exercise-16-known-hosts/       # Exercise 16 - SSH helper scripts
├── exercise-17-host-metadata/     # Exercise 17 - Module-based metadata
├── modules/                       # Shared reusable modules
│   ├── host_metadata/
│   └── SshKnownHosts/
├── .env.example                   # Environment variables template
└── README.md                      # This file
```

## Learning Path

Each exercise builds incrementally on the previous one:

### [Exercise 13: Base System](./base/)
**Start here!** Learn Terraform basics by creating a minimal server.

**What you'll build:**
- Basic Hetzner Cloud server
- SSH key management
- Firewall configuration
- Terraform outputs

**Key concepts:** Resources, variables, providers

---

### [Exercise 14: Nginx Automation](./exercise-14-nginx/)
Add automatic software installation using `user_data`.

**What's new:**
- HTTP firewall rule (port 80)
- Bash script for Nginx installation
- User data automation

**Key concepts:** user_data, cloud provisioning scripts

---

### [Exercise 15: Cloud-init](./exercise-15-cloud-init/)
Replace bash scripts with industry-standard cloud-init configuration.

**What's new:**
- Cloud-init YAML configuration
- Multiple SSH keys support
- DevOps user creation (non-root)
- SSH hardening (no passwords, no root)
- UFW firewall
- Fail2ban intrusion prevention
- Custom Nginx landing page

**Key concepts:** cloud-init, template functions, security hardening

---

### [Exercise 16: SSH Known Hosts](./exercise-16-known-hosts/)
Solve SSH known_hosts management with deployment-specific helpers.

**What's new:**
- Deployment-scoped `known_hosts` file
- SSH wrapper script (`bin/ssh`)
- SCP wrapper script (`bin/scp`)
- `null_resource` with `local-exec`
- Generated helper scripts

**Key concepts:** null resources, local provisioners, ssh-keyscan, templates

---

### [Exercise 17: Host Metadata](./exercise-17-host-metadata/)
Complete configuration with modular architecture and metadata generation.

**What's new:**
- Custom Terraform module (`host_metadata`)
- Auto-incrementing server names
- JSON metadata file generation
- Data sources for querying existing infrastructure
- Production-ready structure

**Key concepts:** modules, data sources, for expressions, project organization

---

## Quick Start

### Prerequisites

1. **Hetzner Cloud Account** - Sign up at [hetzner.com](https://www.hetzner.com/cloud)
2. **Terraform** - Install from [terraform.io](https://www.terraform.io/downloads)
3. **SSH Key** - Generate with: `ssh-keygen -t ed25519`

### Start with Exercise 13

**Recommended: Use .env file (works for all exercises)**

```bash
# 1. Set up environment variables
cd terraform
cp .env.example .env
nano .env  # Edit with your values

# 2. Source the environment file
source .env

# 3. Navigate to exercise
cd base  # or any exercise directory

# 4. Initialize Terraform
terraform init

# 5. Preview changes
terraform plan

# 6. Create infrastructure
terraform apply

# 7. SSH to your server
ssh root@$(terraform output -raw server_ip)

# 8. Clean up
terraform destroy
```

**Alternative: Use terraform.tfvars (per-exercise)**

See `terraform.tfvars.example` in each exercise directory. Less convenient as you need to set it up separately for each exercise.

For more details on secrets management including SOPS encryption, see [SECRETS-MANAGEMENT.md](./SECRETS-MANAGEMENT.md)

## Documentation

- **Exercise READMEs** - Each directory has detailed instructions
- **[Module Documentation](./modules/README.md)** - Reusable module documentation
- **[Course Docs](../docs/exercises/)** - Comprehensive exercise guides
  - [Exercise 13: Base System](../docs/exercises/13-base-system.md)
  - [Exercise 14: Nginx Automation](../docs/exercises/14-nginx-automation.md)
  - [Exercise 15: Cloud-init](../docs/exercises/15-cloud-init.md)
  - [Exercise 16: SSH Known Hosts](../docs/exercises/16-ssh-known-hosts.md)
  - [Exercise 17: Host Metadata](../docs/exercises/17-host-metadata.md)

## Environment Setup

### Recommended: .env File (One Setup for All Exercises)

This is the **easiest and recommended** method:

```bash
# 1. Copy the example file
cd terraform
cp .env.example .env

# 2. Edit with your actual values
nano .env

# 3. Source before using Terraform
source .env

# 4. Now use any exercise directory
cd base  # or exercise-14-nginx, etc.
terraform init
terraform plan
```

**Advantages:**
- One configuration works for all exercises
- Easy to switch between exercises
- All variables documented in one place
- Can be sourced from anywhere in the repo

### Alternative: terraform.tfvars (Per-Exercise)

If you prefer per-exercise configuration:

```bash
cd terraform/base  # or any exercise
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
terraform plan
```

**NEVER commit `terraform.tfvars` or `.env` to git!**

### Advanced: SOPS Encryption

For team collaboration and production use, consider encrypting your secrets with SOPS. See [SECRETS-MANAGEMENT.md](./SECRETS-MANAGEMENT.md) for details.

## Common Commands

```bash
# Initialize (first time or after adding modules)
terraform init

# Format code
terraform fmt

# Validate configuration
terraform validate

# Plan changes
terraform plan

# Apply changes
terraform apply

# Show current state
terraform show

# List resources
terraform state list

# Get output value
terraform output server_ip

# Destroy everything
terraform destroy

# Destroy specific resource
terraform destroy -target=hcloud_server.main_server
```

## Security Best Practices

1. **Never commit secrets** - Use `.gitignore` for `.tfvars`, `.env`
2. **Use SSH keys** - Disable password authentication
3. **Non-root user** - Create devops user with sudo
4. **Firewall rules** - Only open required ports
5. **Enable Fail2ban** - Automatic intrusion prevention
6. **Keep packages updated** - Use cloud-init package updates
7. **Use strong SSH keys** - Ed25519 recommended

## Git Ignore

All exercises include proper `.gitignore` files that exclude:

```
*.tfstate*           # State files (contain sensitive data)
.terraform/          # Provider plugins
terraform.tfvars     # Your variables (may contain secrets)
.env                 # Environment variables
gen/                 # Generated files
bin/                 # Generated scripts
```

## Troubleshooting

### Terraform init fails
```bash
rm -rf .terraform .terraform.lock.hcl
terraform init
```

### State file issues
```bash
# Remove lock
terraform force-unlock <lock-id>

# Refresh state
terraform refresh
```

### Provider issues
```bash
# Update providers
terraform init -upgrade
```

### Can't SSH to server
- Wait 2-3 minutes for cloud-init to complete
- Check: `cloud-init status --wait` on the server
- Check firewall: `sudo ufw status`
- Verify SSH key is correct

## Next Steps

After completing all exercises:

1. **Add More Modules** - Create modules for common patterns
2. **Remote State** - Use S3 or Terraform Cloud for state storage
3. **Workspaces** - Manage multiple environments (dev, staging, prod)
4. **CI/CD Pipeline** - Automate with GitHub Actions or GitLab CI
5. **Testing** - Add Terratest for automated testing
6. **Multi-Cloud** - Extend to AWS, Azure, or GCP
7. **Kubernetes** - Deploy K3s cluster with Terraform

## Resources

### Official Documentation
- [Terraform Documentation](https://www.terraform.io/docs)
- [Hetzner Cloud Provider](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs)
- [Cloud-init Documentation](https://cloudinit.readthedocs.io/)

### Terraform Learning
- [HashiCorp Learn](https://learn.hashicorp.com/terraform)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

### Hetzner Cloud
- [Hetzner Cloud API](https://docs.hetzner.cloud/)
- [Hetzner Cloud Console](https://console.hetzner.cloud/)

## License

This is educational material for the Software Defined Infrastructure course.

---

Start with [Exercise 13: Base System](./base/) and work your way up!
