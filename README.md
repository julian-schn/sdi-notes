# SDI Notes 🚀

[![Deploy VitePress to GitHub Pages](https://github.com/julian-schn/sdi-notes/actions/workflows/deploy.yml/badge.svg)](https://github.com/julian-schn/sdi-notes/actions/workflows/deploy.yml)

Comprehensive lecture notes, documentation, and hands-on resources for the **113475a Software Defined Infrastructure** course.

## Quick Links

- **Live Documentation:** [julian-schn.github.io/sdi-notes](https://julian-schn.github.io/sdi-notes/)
- **Infrastructure As Code:** [docs/iac/](docs/iac/index.md)
- **Exercises:** [docs/exercises/](docs/exercises/index.md)

---

## About

Notes and Terraform code for the **113475a Software Defined Infrastructure** course at HdM Stuttgart. Covers Terraform on Hetzner Cloud, cloud-init, DNS, certificates, private networking, and more.

Topics include:
- Infrastructure as Code with Terraform and the Hetzner Cloud provider
- Server provisioning and automation via cloud-init
- DNS management, TLS certificates with Let's Encrypt
- Private subnets, jump hosts, and application-level proxies

---

## Running the Terraform Exercises

### Credentials

Run `./scripts/setup.sh` once — it creates `terraform/.env` (gitignored) with:

- `HCLOUD_TOKEN` — Hetzner Cloud API token (from console.hetzner.cloud → API Tokens)
- `TF_VAR_ssh_public_key` — your SSH public key (auto-detected from `~/.ssh/id_ed25519.pub`)
- `TF_VAR_dns_secret` — TSIG secret from your `dnsupdate.sec` file (required for exercises 22–29)

### Running an Exercise

```bash
source terraform/.env
make E=14 apply     # deploy
make E=14 destroy   # tear down
make help           # list all available targets
```

---

## Local Development

This project is built using [VitePress](https://vitepress.dev/). 

### Prerequisites
- [Node.js](https://nodejs.org/) (v18 or higher recommended)
- `npm` (comes with Node.js)

### Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/julian-schn/sdi-notes.git
   cd sdi-notes
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Run the development server:**
   ```bash
   npm run dev
   ```
   *The documentation will be active at `http://localhost:5173`.*

### Other Commands

| Command | Description |
|---------|-------------|
| `npm run docs:build` | Build the documentation for production |
| `npm run docs:preview` | Preview the local production build |

---

## Contributing

Found a mistake or want to add something? Open an issue or submit a PR.
