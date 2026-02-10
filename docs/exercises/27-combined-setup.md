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
```bash
terraform apply  # One-click deploy
# Wait ~2 mins
curl https://www.g3...  # Works immediately!
```

## Problems & Learnings
**Race Condition:** Terraform must create the cert before the server reads it. Referencing `acme_certificate.wildcard.certificate_pem` ensures correct ordering.

## Related Exercises
- [25 - Web Certificate](./25-web-certificate.md)
- [26 - Testing Certificate](./26-testing-certificate.md)
