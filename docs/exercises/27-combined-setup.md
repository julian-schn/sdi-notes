# 27 - Combined Setup (Certificate + Server)

> **Working Code:** [`terraform/exercise-27-combined-certificate/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-27-combined-certificate/)

**The Problem:** Generating cert → SCP to server → configure Nginx → restart... too much manual work.

**The Solution:** Use Terraform dependencies and cloud-init to do it all in one `terraform apply`.

## Objective
One command that:
1. Generates certificate (ACME)
2. Spawns server (HCloud)
3. Injects cert during boot (Cloud-Init)
4. Configures Nginx

## How-to

### 1. Generate Certificate
```hcl
resource "acme_certificate" "wildcard" {
  # ... (Same as Ex 25)
}
```

### 2. Pass to Cloud-Init
```hcl
user_data = templatefile("cloud-init.yaml", {
  cert_pem = acme_certificate.wildcard.certificate_pem
  key_pem  = acme_certificate.wildcard.private_key_pem
})
```

### 3. Cloud-Init Writes Files
```yaml
write_files:
  - path: /etc/ssl/certs/fullchain.pem
    content: ${cert_pem}
  - path: /etc/ssl/private/privkey.pem
    content: ${key_pem}
  - path: /etc/nginx/sites-available/default
    content: |
      server {
        listen 443 ssl;
        ssl_certificate /etc/ssl/certs/fullchain.pem;
        ssl_certificate_key /etc/ssl/private/privkey.pem;
      }

runcmd:
  - systemctl restart nginx
```

## Verification
1. Apply configuration: `terraform apply`
2. Test HTTP redirects to HTTPS: `curl http://g2.sdi.hdm-stuttgart.cloud` — expect `301 Moved Permanently`
3. Test HTTPS with staging cert (skip CA verification): `curl -k https://g2.sdi.hdm-stuttgart.cloud`
4. Verify certificate in browser — expect warning with staging cert, inspect to confirm both SANs present
5. Switch to production ACME URL in Exercise 25 and re-apply if staging works

## Problems & Learnings

::: warning Common Issues
- `curl https://...` will fail with a certificate error when using staging — this is expected. Use `curl -k` to bypass or test in a browser.
- The ACME certificate must be generated **before** the server is created, as the certificate content is passed to cloud-init. Terraform handles this ordering automatically via resource dependencies.
:::

::: tip Key Takeaways
- HTTP → HTTPS redirect is configured via Nginx; `curl` against port 80 returns a 301.
- Staging certificates are functionally identical to production for testing the full chain — only browser/system trust differs.
:::

## Related Exercises
- [25 - Web Certificate](./25-web-certificate.md)
- [26 - Testing Certificate](./26-testing-certificate.md)
