# 17 - Host Metadata Generation

> **Working Code:** [`terraform/exercise-17-host-metadata/`](../../terraform/exercise-17-host-metadata/)

- Goal: Implement module-based host creation that automatically generates a metadata JSON file for each host.

TLDR:
- A root module `CreateHostByModule` calls a reusable `host_metadata` module.
- The `host_metadata` module uses `templatefile` to render a JSON file from variables.
- The generated file is saved to a `Gen/` directory with the host's name.

1) Create the Host Metadata Module:
```hcl
# modules/host_metadata/variables.tf
variable "name" { type = string }
variable "ipv4" { type = string }
variable "ipv6" { type = string }
variable "location" { type = string }

# modules/host_metadata/tpl/hostdata.json
{
  "ipv4": "${ip4}",
  "ipv6": "${ip6}",
  "location": "${location}"
}

# modules/host_metadata/main.tf
resource "local_file" "hostdata" {
  content = templatefile("${path.module}/tpl/hostdata.json", {
      ip4      = var.ipv4
      ip6      = var.ipv6
      location = var.location
  })
  filename = "Gen/${var.name}.json"
}
```

2) Create the Root Module:
```hcl
# CreateHostByModule/main.tf
module "host_metadata" {
  source = "../modules/host_metadata"

  name     = var.name
  ipv4     = "192.168.1.10"
  ipv6     = "2001:db8::1"
  location = "fsn1"
}

# CreateHostByModule/variables.tf
variable "name" {
  type    = string
  default = "web-server-01"
}
```

3) Verify:
- Run `terraform init` and `terraform plan` in `terraform/CreateHostByModule`.
- Check that `Gen/web-server-01.json` is planned for creation with the correct content.
