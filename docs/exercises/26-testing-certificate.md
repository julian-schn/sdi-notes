# 26 - Testing Your Certificate

> **Working Code:** [`terraform/exercise-26-testing-certificate/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-26-testing-certificate/)

**The Problem:** You have certificate files from Exercise 25, but the server uses self-signed (snakeoil) cert.

**The Solution:** Copy certs to server and configure Nginx.

## Objective
Create server responding to `https://www.g3...` with valid Let's Encrypt certificate.

## How-to

### 1. Variables
```hcl
variable "dns_zone" {
  default = "g3.sdi.hdm-stuttgart.cloud"
}
```

### 2. Manual Installation
We'll automate this in Exercise 27. For now, understand the steps:

```bash
# 1. Copy files
scp gen/certificate.pem root@<ip>:/etc/ssl/certs/fullchain.pem
scp gen/private.pem root@<ip>:/etc/ssl/private/privkey.pem

# 2. Configure Nginx
# Edit /etc/nginx/sites-available/default:
server {
    listen 443 ssl;
    server_name www.g3.sdi.hdm-stuttgart.cloud;
    ssl_certificate /etc/ssl/certs/fullchain.pem;
    ssl_certificate_key /etc/ssl/private/privkey.pem;
}

# 3. Reload
systemctl reload nginx

# 4. Test
curl -v https://www.g3...
```

## Related Exercises
- [27 - Combined Setup](./27-combined-setup.md)
