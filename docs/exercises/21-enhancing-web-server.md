# 21 - Enhancing Your Web Server (DNS & TLS)

> **Working Code:** [`terraform/exercise-21-enhancing-web-server/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-21-enhancing-web-server/)

**The Problem:** Accessing websites via IP address (`http://49.12.34.56`) looks unprofessional and is hard to remember. Also, HTTP is insecure.

**The Solution:** Use Terraform to configure **DNS** (for a nice name) and **Certbot** (for free HTTPS).

## Objective
Point `g2.sdi.hdm-stuttgart.cloud` to your server's IP and secure it with Let's Encrypt.

## How-to

### 1. Terraform: DNS Records
Use the `dns` provider (or your specific provider like Cloudflare/AWS) to create records:

```hcl
# The Provider (using TSIG keys)
provider "dns" {
  update {
    server     = "ns1.sdi.hdm-stuttgart.cloud"
    key_name   = "g2.key."
    key_secret = var.dns_secret
  }
}

# The Record
resource "dns_a_record_set" "www" {
  zone = "sdi.hdm-stuttgart.cloud."
  name = "www.g2"
  addresses = [hcloud_server.web.ipv4_address]
  ttl = 300
}
```

### 2. Manual: Get the Certificate
Once the DNS resolves (check with `host www.g2...`), SSH into the server and run Certbot:

```bash
# Install Certbot
apt update && apt install -y certbot python3-certbot-nginx

# Run it (Staging first!)
certbot --nginx -d www.g2.sdi.hdm-stuttgart.cloud --staging

# If that works, run for real:
certbot --nginx -d www.g2.sdi.hdm-stuttgart.cloud --force-renewal
```

## Verification
1. `terraform apply` -> DNS record created.
2. `host www.g2.sdi.hdm-stuttgart.cloud` -> Returns your IP.
3. Open `https://www.g2.sdi.hdm-stuttgart.cloud` -> Lock icon appears!

## Related Exercises
- [25 - Web Certificate](./25-web-certificate.md) - Automating the certificate part with Terraform
