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

## Problems & Learnings

::: warning Common Issues
- **`certbot: command not found`** — certbot is not included in the cloud-init package list. Install it manually: `sudo apt-get install -y certbot python3-certbot-nginx`
- **`curl -I https://...` fails with SSL error** — expected with a staging certificate. The staging CA is not trusted by default. Use `curl -Ik` to skip verification, or open in a browser and bypass the warning.
:::

::: tip Key Takeaways
- Always use `--staging` first — Let's Encrypt production has strict rate limits; hitting them will lock you out for hours
- The staging certificate is functionally identical to production for testing nginx config — the only difference is the untrusted CA
- `python3-certbot-nginx` is required alongside `certbot` for the `--nginx` plugin to work
:::

## Related Exercises
- [25 - Web Certificate](./25-web-certificate.md)
