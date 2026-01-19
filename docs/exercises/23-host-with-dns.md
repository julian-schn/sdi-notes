# 23 - Creating a host with corresponding DNS entries

> **Working Code:** [`terraform/exercise-23-dns-host/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-23-dns-host/)

Extend [Solving the ~/.ssh/known_hosts quirk](./16-ssh-known-hosts) by adding DNS records like in [Creating DNS records](./22-creating-dns-records). The provider generated IP4 address shall be bound to `workhorse` within your given zone.

Use the server's common DNS name rather than its IP in the generated `gen/known_hosts`, `bin/ssh` and `bin/scp` files, e.g:

**`gen/known_hosts`:**

```text
workhorse.gxy.sdi.hdm-stuttgart.cloud ssh-ed25519 AAAAC3N...at8e8JL3rr
```

**`bin/ssh`:**

```bash
#!/usr/bin/env bash

GEN_DIR=$(dirname "$0")/../gen

ssh -o UserKnownHostsFile="$GEN_DIR/known_hosts" devops@workhorse.gxy.sdi.hdm-stuttgart.cloud "$@"
```
