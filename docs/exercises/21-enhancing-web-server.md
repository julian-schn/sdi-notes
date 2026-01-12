# 21 - Enhancing your web server

> **Working Code:** [`terraform/exercise-21-enhancing-web-server/`](../../terraform/exercise-21-enhancing-web-server/)

- Goal: Add DNS records and enable TLS with Let's Encrypt for your web server.

## DNS Configuration

Provide DNS «A» records pointing to your server's IP address for:

- `http://www.g2.sdi.hdm-stuttgart.cloud`
- `http://g2.sdi.hdm-stuttgart.cloud`

### Provider Setup

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

> **Note:** The `key_secret` is the base64-encoded part of your HMAC key from `dnsupdate.sec`, not the full `hmac-sha512:g2.key:...` string.

### Apex Record Workaround

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

## TLS Configuration

Follow "How To Secure Nginx with Let's Encrypt on Debian" and configure TLS for both domains.

**Important:**

- **Firewall**: Skip firewall steps—you already have a Hetzner firewall.
- **Rate Limits**: Use staging first to avoid Let's Encrypt rate limits.

## Verification

1. **Apply Terraform**:

   ```bash
   source ../.env
   terraform apply
   ```

2. **Wait for cloud-init** (~2-3 minutes):

   ```bash
   ssh devops@g2.sdi.hdm-stuttgart.cloud "sudo cloud-init status --wait"
   ```

3. **Get staging certificate** (test first):

   ```bash
   sudo certbot --nginx -d g2.sdi.hdm-stuttgart.cloud -d www.g2.sdi.hdm-stuttgart.cloud --staging
   ```

4. **Get production certificate**:

   ```bash
   sudo certbot --nginx -d g2.sdi.hdm-stuttgart.cloud -d www.g2.sdi.hdm-stuttgart.cloud --force-renewal
   ```

5. **Verify HTTPS**:

   ```bash
   curl -I https://g2.sdi.hdm-stuttgart.cloud
   curl -I https://www.g2.sdi.hdm-stuttgart.cloud
   ```

Both should return `HTTP/1.1 200 OK` with a valid TLS connection.
