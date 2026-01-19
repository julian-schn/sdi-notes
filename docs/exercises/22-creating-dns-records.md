# 22 - Creating DNS records

> **Working Code:** [`terraform/exercise-22-creating-dns-records/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-22-creating-dns-records/)

## Goal
Starting from a domain `g02.sdi.hdm-stuttgart.cloud`, we use Terraform to create:

1.  An **A record** `workhorse.g02...` resolving to `1.2.3.4`.
2.  An **A record** `g02...` resolving to `1.2.3.4`.
3.  Two **CNAME aliases** `www` and `mail` referencing `workhorse`.

## Configuration

We use variables for flexibility and strict validation rules to prevent configuration errors.

### Variables (`variables.tf`)

```hcl
variable "server_name" {
  default = "workhorse"
}

variable "server_aliases" {
  default = ["www", "mail"]

  # Rule 1: No Duplicates
  validation {
    condition     = length(distinct(var.server_aliases)) == length(var.server_aliases)
    error_message = "Duplicate server alias names found."
  }

  # Rule 2: No Name Conflict
  validation {
    condition     = !contains(var.server_aliases, var.server_name)
    error_message = "Server alias name matches server's common name."
  }
}
```

### Main Logic (`main.tf`)

We use the standard `count` meta-argument to iterate over aliases:

```hcl
resource "hetznerdns_record" "aliases" {
  count = length(var.server_aliases)
  # ...
  name  = var.server_aliases[count.index]
  value = "${var.server_name}.${var.dns_zone}."
  type  = "CNAME"
}
```

## Verification
Run `terraform apply` and verify with `dig`:

```bash
dig +noall +answer @ns1.hdm-stuttgart.cloud g02.sdi.hdm-stuttgart.cloud
dig +noall +answer @ns1.hdm-stuttgart.cloud workhorse.g02.sdi.hdm-stuttgart.cloud
```
