# 21 - Enhancing your web server

> **Working Code:** [`terraform/exercise-21-enhancing-web-server/`](../../terraform/exercise-21-enhancing-web-server/)

## Goal
Enhance your web server from "Improve your server's security!" by adding DNS records and enabling TLS with Let's Encrypt.

## Tasks

### 1. DNS Configuration
Provide DNS »A« records pointing to your server's IP address for:

- `http://www.g02.sdi.hdm-stuttgart.cloud`
- `http://g02.sdi.hdm-stuttgart.cloud`

### 2. TLS Configuration
Follow "How To Secure Nginx with Let's Encrypt on Debian 11" and configure TLS allowing for access by both:

- `https://www.g02.sdi.hdm-stuttgart.cloud`
- `https://g02.sdi.hdm-stuttgart.cloud`

**Important constraints:**
- **Firewall**: Omit the firewall related steps. You already have a Hetzner firewall rule set in place.
- **Rate Limits**: Avoid becoming a Letsencrypt rate limit victim. Use the staging environment first.

### 3. Staging Certificate
Use the `--staging` (or `--test-cert`) option to validate your configuration first.
Let's Encrypt's staging environment is far more lenient (e.g., a failed validation limit of 60 per hour versus 5).

- Staging ACME URL: `https://acme-staging-v02.api.letsencrypt.org/directory`
- Production ACME URL: `https://acme-v02.api.letsencrypt.org/directory`

### 4. Production Certificate
After successfully creating, installing, and testing your Letsencrypt staging certificate, re-create your certificate omitting the `--staging` option to get a valid certificate.
