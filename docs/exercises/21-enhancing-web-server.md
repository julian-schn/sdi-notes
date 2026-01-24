# 21 - Enhancing Your Web Server

> **Working Code:** [`terraform/exercise-21-enhancing-web-server/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-21-enhancing-web-server/)

## Overview
Add DNS records and enable TLS with Let's Encrypt for your web server. This exercise demonstrates DNS configuration and certificate management for production-ready HTTPS setup.

## Prerequisites
- Completed cloud-init based web server setup
- Access to HDM Stuttgart DNS zone
- Understanding of DNS A records and CNAME records
- Familiarity with Let's Encrypt certificate process

## Objective
Add DNS A records pointing to your server's IP address and enable TLS with Let's Encrypt for secure HTTPS access.

## Implementation

### Step 1: DNS Configuration
Provide DNS A records pointing to your server's IP address for:
- `http://www.g2.sdi.hdm-stuttgart.cloud`
- `http://g2.sdi.hdm-stuttgart.cloud`

#### Provider Setup
The `hashicorp/dns` provider uses TSIG authentication with the HDM Stuttgart nameserver:

```hcl
provider "dns" {
  update {
    server        = "ns1.sdi.hdm-stuttgart.cloud"
    key_name      = "g2.key."
    key_algorithm = "hmac-sha512"
    key_secret    = var.dns_secret
  }
}
```

::: warning Key Secret Format
The `key_secret` is the base64-encoded part of your HMAC key from `dnsupdate.sec`, not the full `hmac-sha512:g2.key:...` string.
:::

#### Apex Record Workaround
The `hashicorp/dns` provider doesn't support apex/root zone records (using `@` or empty name). Use a `null_resource` with `nsupdate` as a workaround:

```hcl
resource "null_resource" "dns_root" {
  triggers = {
    server_ip = hcloud_server.web_server.ipv4_address
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "server ns1.sdi.hdm-stuttgart.cloud
      update add ${var.project}.sdi.hdm-stuttgart.cloud. 10 A ${hcloud_server.web_server.ipv4_address}
      send" | nsupdate -y "hmac-sha512:${var.project}.key:${var.dns_secret}"
    EOT
  }
}
```

### Step 2: TLS Configuration
Follow "How To Secure Nginx with Let's Encrypt on Debian" and configure TLS for both domains.

::: danger Important Notes
- **Firewall**: Skip firewall steps—you already have a Hetzner firewall
- **Rate Limits**: Use staging first to avoid Let's Encrypt rate limits
:::

## Verification

### Step 1: Apply Terraform
```bash
source ../.env
terraform apply
```

### Step 2: Wait for Cloud-init
Wait for cloud-init to complete (~2-3 minutes):

```bash
ssh devops@g2.sdi.hdm-stuttgart.cloud "sudo cloud-init status --wait"
```

### Step 3: Get Staging Certificate
Test first with staging to avoid rate limits:

```bash
sudo certbot --nginx -d g2.sdi.hdm-stuttgart.cloud -d www.g2.sdi.hdm-stuttgart.cloud --staging
```

### Step 4: Get Production Certificate
Once staging works, get the production certificate:

```bash
sudo certbot --nginx -d g2.sdi.hdm-stuttgart.cloud -d www.g2.sdi.hdm-stuttgart.cloud --force-renewal
```

### Step 5: Verify HTTPS
Test both domains:

```bash
curl -I https://g2.sdi.hdm-stuttgart.cloud
curl -I https://www.g2.sdi.hdm-stuttgart.cloud
```

Both should return `HTTP/1.1 200 OK` with a valid TLS connection.

## Problems & Learnings

::: warning Common Issues
*This section will be filled in collaboratively. Common issues encountered during this exercise will be documented here.*
:::

::: tip Key Takeaways
*Key learnings and best practices from this exercise will be documented here.*
:::

## Related Exercises
- [22 - Creating DNS Records](./22-creating-dns-records.md) - Systematic DNS record creation
- [25 - Web Certificate](./25-web-certificate.md) - Terraform-managed certificates
