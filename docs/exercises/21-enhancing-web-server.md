# 21 - Enhancing Web Server (DNS & TLS)

> **Working Code:** [`terraform/exercise-21-enhancing-web-server/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-21-enhancing-web-server/)

**The Problem:** Accessing websites via IP (`http://49.12.34.56`) looks unprofessional and is insecure.

**The Solution:** Use Terraform for DNS and Certbot for HTTPS.

## Objective
Point `g2.sdi.hdm-stuttgart.cloud` to your server and secure it with Let's Encrypt.

## How-to

### 1. DNS Records
```hcl
resource "dns_a_record_set" "www" {
  zone = "sdi.hdm-stuttgart.cloud."
  name = "www.g2"
  addresses = [hcloud_server.web.ipv4_address]
  ttl = 300
}
```

### 2. Get Certificate (Manual)
SSH into server and run Certbot:

```bash
apt update && apt install -y certbot python3-certbot-nginx

# Test with staging first
certbot --nginx -d www.g2.sdi.hdm-stuttgart.cloud --staging

# Then for real
certbot --nginx -d www.g2.sdi.hdm-stuttgart.cloud --force-renewal
```

## Verification
```bash
terraform apply
host www.g2.sdi.hdm-stuttgart.cloud  # Returns your IP
curl https://www.g2...  # Lock icon!
```

## Related Exercises
- [25 - Web Certificate](./25-web-certificate.md)
