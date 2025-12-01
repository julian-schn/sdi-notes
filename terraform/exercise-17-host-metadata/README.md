# Exercise 17 - Host Metadata Generation

This exercise introduces **Terraform modules** and demonstrates how to generate structured metadata files for each host. This is the culmination of all previous exercises, showing a complete, production-ready Terraform configuration.

## What's New in Exercise 17

- **Custom Terraform Module** - Reusable `host_metadata` module
- **Auto-incrementing Server Names** - Servers named `server-1`, `server-2`, etc.
- **Metadata JSON Generation** - Each server gets a metadata file with its details
- **Modular Architecture** - Demonstrates code reusability and organization

## What You'll Learn

- Creating and using Terraform modules
- Querying existing infrastructure with data sources
- Auto-incrementing resource names
- Template-based file generation
- Structuring complex Terraform projects

## What's Included

This is the **complete** configuration with everything from Exercises 13-16 plus:

1. **Auto-naming** - Servers are automatically numbered based on existing servers
2. **Host Metadata Module** - Generates JSON files with server information
3. **All Previous Features**:
   - Cloud-init configuration
   - SSH hardening
   - UFW firewall
   - Fail2ban
   - Nginx with custom landing page
   - SSH/SCP wrapper scripts
   - Deployment-specific known_hosts

## Prerequisites

- Understanding of Exercises 13-16
- Hetzner Cloud account with API token
- Terraform installed (>= 1.0)
- SSH key pair

## Project Structure

```
exercise-17-host-metadata/
├── main.tf                    # Main configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── cloud-init.yaml            # Cloud-init template
├── terraform.tfvars.example   # Example variables
├── .gitignore                 # Git ignore rules
├── tpl/                       # Script templates
│   ├── ssh.sh
│   └── scp.sh
├── modules/                   # Custom modules
│   └── host_metadata/         # Host metadata module
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── tpl/
│           └── hostdata.json
├── gen/                       # Generated (not in git)
│   ├── known_hosts
│   └── server-1.json
└── bin/                       # Generated (not in git)
    ├── ssh
    └── scp
```

## Usage

1. **Copy the example variables file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars`:**
   ```hcl
   ssh_public_key = file("~/.ssh/id_ed25519.pub")
   devops_username = "devops"
   server_base_name = "server"
   ```

3. **Set your Hetzner API token:**
   ```bash
   export HCLOUD_TOKEN="your-api-token-here"
   ```

4. **Initialize and apply:**
   ```bash
   terraform init
   terraform apply
   ```

5. **Check the generated metadata:**
   ```bash
   cat gen/server-1.json
   ```

   You'll see:
   ```json
   {
     "ipv4": "123.45.67.89",
     "ipv6": "2001:db8::1",
     "location": "nbg1"
   }
   ```

6. **Connect using wrapper scripts:**
   ```bash
   ./bin/ssh
   ```

## How It Works

### 1. Auto-incrementing Server Names

The configuration queries existing servers and finds the next available number:

```hcl
data "hcloud_servers" "existing" {}

locals {
  existing_server_numbers = [
    for server in data.hcloud_servers.existing.servers :
    tonumber(regex("^${var.server_base_name}-(\\d+)$", server.name)[0])
    if can(regex("^${var.server_base_name}-(\\d+)$", server.name))
  ]
  next_server_number = length(local.existing_server_numbers) > 0 ?
                       max(local.existing_server_numbers...) + 1 : 1
  server_name = "${var.server_base_name}-${local.next_server_number}"
}
```

### 2. Host Metadata Module

The module is called with server details:

```hcl
module "host_metadata" {
  source = "./modules/host_metadata"

  name     = local.server_name
  ipv4     = hcloud_server.main_server.ipv4_address
  ipv6     = hcloud_server.main_server.ipv6_address
  location = hcloud_server.main_server.location
}
```

Inside the module (`modules/host_metadata/main.tf`):

```hcl
resource "local_file" "hostdata" {
  content = templatefile("${path.module}/tpl/hostdata.json", {
    ip4      = var.ipv4
    ip6      = var.ipv6
    location = var.location
  })
  filename = "gen/${var.name}.json"
}
```

### 3. Multiple Server Support

Run `terraform apply` multiple times to create `server-1`, `server-2`, `server-3`, etc. Each gets its own metadata file.

## Verification

### 1. Check Server Name

```bash
terraform output server_name
# Should show: server-1 (or server-2, etc.)
```

### 2. Check Metadata File

```bash
cat $(terraform output -raw metadata_file_path)
```

### 3. Create Multiple Servers

```bash
# Create first server
terraform apply

# Create second server (without destroying first)
terraform apply

# List all servers
hcloud server list
# Should show: server-1, server-2
```

### 4. Test All Features

```bash
# SSH wrapper
./bin/ssh "hostname"

# Nginx
curl $(terraform output -raw nginx_url)

# Metadata
jq '.' gen/server-*.json
```

## Module Benefits

✅ **Reusability** - Use the module for any server
✅ **Encapsulation** - Module logic is self-contained
✅ **Testability** - Test modules independently
✅ **Maintainability** - Update module once, affects all uses
✅ **Sharing** - Share modules across projects or teams

## Advanced Usage

### Use the Module Standalone

```hcl
# In another project
module "host_metadata" {
  source = "../exercise-17-host-metadata/modules/host_metadata"

  name     = "custom-server"
  ipv4     = "192.168.1.100"
  ipv6     = "2001:db8::100"
  location = "fsn1"
}
```

### Extend the Metadata

Edit `modules/host_metadata/tpl/hostdata.json`:

```json
{
  "ipv4": "${ip4}",
  "ipv6": "${ip6}",
  "location": "${location}",
  "created_at": "${timestamp}",
  "environment": "${environment}"
}
```

Add variables to the module:

```hcl
variable "timestamp" { type = string }
variable "environment" { type = string }
```

## Troubleshooting

**Server naming conflicts?**
- The data source queries existing servers
- Make sure `server_base_name` matches your naming pattern
- Check: `hcloud server list`

**Module not found?**
```bash
terraform init
# Re-initializes and downloads/links modules
```

**Metadata file in wrong location?**
- Check `gen/` directory exists
- Module uses relative path from root

## Next Steps

This is the final exercise! You now have:
- ✅ Basic server provisioning (Ex 13)
- ✅ Automated software installation (Ex 14)
- ✅ Advanced cloud-init (Ex 15)
- ✅ SSH helper scripts (Ex 16)
- ✅ Modular architecture (Ex 17)

**Continue learning:**
- Create more modules (firewall, load balancer, etc.)
- Add remote state backend (S3, Terraform Cloud)
- Implement workspaces for multi-environment
- Add automated testing with Terratest
- Set up CI/CD pipeline

## Cleanup

```bash
terraform destroy
```

## Learn More

- [Terraform Modules Documentation](https://developer.hashicorp.com/terraform/language/modules)
- [Module Best Practices](https://developer.hashicorp.com/terraform/language/modules/develop)
- [Data Sources](https://developer.hashicorp.com/terraform/language/data-sources)
- [For Expressions](https://developer.hashicorp.com/terraform/language/expressions/for)
