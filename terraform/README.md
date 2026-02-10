# Terraform Infrastructure as Code

This directory contains incremental Terraform exercises for learning infrastructure automation with Hetzner Cloud.

## Exercise Structure

These exercises follow different learning patterns:

### 🔗 Sequential Progressions (Run One After Another)

Some exercises build on each other and **share the same DNS zone**. Complete them in order, destroying the previous before starting the next:

**Path 1: DNS & Web Server** (Exercises 21-24)

```
Ex 21 (Basic Web) → Ex 22 (DNS) → Ex 23 (DNS Host) → Ex 24 (Multi-server)
```

- All use `project = "g2"` and `dns_zone = "g2.sdi.hdm-stuttgart.cloud"`
- Each builds on previous concepts
- **Only one active at a time** in the g2 zone

**Path 2: HTTPS Certificates** (Exercises 25-27)

```
Ex 25 (Cert Generation) → Ex 26 (Cert Testing) 
                     OR → Ex 27 (Combined)
```

- Ex 25: Certificate generation only (optional deep-dive)
- Ex 26: Self-contained cert + server (recommended)
- Ex 27: Alternative combined approach
- All use g2 zone for DNS challenges

**Path 3: Private Networks** (Exercises 28-29)

```
Ex 28 (Subnets) → Ex 29 (App Gateway)
```

- Ex 29 builds on Ex 28 concepts but is self-contained
- Use unique project names (ex28, ex29)

### ⚡ Independent Exercises (Run Anytime)

These can run in any order or simultaneously (with unique project names):

- **Ex 14**: Nginx installation
- **Ex 15**: Cloud-init configuration  
- **Ex 16**: SSH known_hosts automation
- **Ex 17**: Host metadata modules
- **Ex 18**: SSH key modules (`project = "ex18"`)
- **Ex 19**: Manual volumes (`project = "ex19"`)
- **Ex 20**: Auto-mounted volumes (`project = "ex20"`)

### 📋 Recommended Learning Order

```
1. Start: Ex 14 (Nginx basics)
2. Cloud: Ex 15 (Cloud-init)
3. DNS:   Ex 21 → 22 → 23
4. HTTPS: Ex 26 or 27
5. Adv:   Ex 28 → 29
```

**Mix in independent exercises** (16, 17, 18, 19, 20) anytime to learn specific concepts.

## How to Use This Repository

### First Time Setup

1. **Prerequisites**
   - [Terraform](https://www.terraform.io/downloads) >= 1.0
   - [Hetzner Cloud Account](https://www.hetzner.com/cloud) with API token
   - SSH key pair (`ssh-keygen -t ed25519`)

2. **Environment Configuration**

   ```bash
   cd terraform
   cp .env.example .env
   nano .env  # Add your HCLOUD_TOKEN, SSH keys, DNS secret
   source .env
   ```

3. **Quick Setup All Exercises** (Optional)

   ```bash
   make full-setup-all  # Initializes and creates config files for all exercises
   ```

### Working with an Exercise

**Method 1: Using Makefile** (Recommended)

```bash
# Setup specific exercise
make E=26 setup      # Initialize + create config.auto.tfvars

# Plan changes
make E=26 plan

# Apply infrastructure
make E=26 apply

# SSH to server
make E=26 ssh

# Destroy infrastructure
make E=26 destroy
```

**Method 2: Direct Terraform**

```bash
# Navigate to exercise
cd terraform/exercise-26-testing-certificate

# Initialize
terraform init

# Create config file
cp config.auto.tfvars.example config.auto.tfvars
nano config.auto.tfvars  # Edit values

# Plan and apply
terraform plan
terraform apply

# SSH to server
ssh devops@$(terraform output -raw server_ip)

# Destroy
terraform destroy
```

### Available Makefile Commands

```bash
make help            # Show all commands
make list            # List all exercises
make status          # Show exercises with active resources
make E=X setup       # Initialize + configure exercise
make E=X plan        # Preview changes
make E=X apply       # Create infrastructure
make E=X destroy     # Destroy infrastructure
make E=X ssh         # SSH to server
make E=X output      # Show outputs
make E=X fmt         # Format code
make E=X validate    # Validate configuration
make clean           # Clean generated files for exercise
make clean-all       # Clean all exercises
make destroy-all     # Destroy all active resources
make full-setup-all  # Set up all exercises
```

### Common Workflows

**Starting a New Exercise**

```bash
# Using Makefile
make E=26 setup    # Interactive configuration
make E=26 plan
make E=26 apply

# Using Terraform directly
cd terraform/exercise-26-testing-certificate
terraform init
cp config.auto.tfvars.example config.auto.tfvars
nano config.auto.tfvars
terraform apply
```

**Switching Between Exercises

```bash
# For independent exercises (14-20): Run concurrently!
make E=18 apply
make E=19 apply  # Different project names, no conflict

# For sequential exercises (21-24, 25-27): Destroy first!
make E=22 destroy
make E=23 apply  # Uses same g2 zone
```

**Testing Changes**

```bash
make E=26 plan     # Preview changes
make E=26 apply    # Apply if good
make E=26 ssh      # Test server
make E=26 destroy  # Clean up
```

### Known Issues & Workarounds

#### Exercise 22: CNAME Import Required

The DNS provider doesn't return state after creating CNAMEs. Import manually:

```bash
cd terraform/exercise-22-creating-dns-records
terraform import 'dns_cname_record.aliases["www"]' www.g2.sdi.hdm-stuttgart.cloud.
terraform import 'dns_cname_record.aliases["mail"]' mail.g2.sdi.hdm-stuttgart.cloud.
```

#### Exercise 26/27: DNS Cleanup Between Exercises

When switching from Exercise 22/23 to 26/27, clean DNS records:

```bash
source terraform/.env
echo "server ns1.sdi.hdm-stuttgart.cloud
update delete www.g2.sdi.hdm-stuttgart.cloud. CNAME
update delete mail.g2.sdi.hdm-stuttgart.cloud. CNAME  
update delete www.g2.sdi.hdm-stuttgart.cloud. A
update delete mail.g2.sdi.hdm-stuttgart.cloud. A
send" | nsupdate -y "hmac-sha512:g2.key:$TF_VAR_dns_secret"
```

#### ACME Rate Limiting

Let's Encrypt has rate limits. If certificate creation times out:

- Wait 2-3 minutes between attempts
- Use staging certificates for testing (`use_production = false`)
- Only switch to production when ready

#### Hetzner Capacity Issues

If you get "resource_unavailable" errors:

- Try different server type (`cx33` is most reliable)
- Try different location (`nbg1`, `fsn1`, `hel1`)
- Wait a few minutes and retry

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

## License

This is educational material for the Software Defined Infrastructure course.

---

Start with [Exercise 13: Base System](./base/) and work your way up!
