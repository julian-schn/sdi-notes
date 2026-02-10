# 7 - SSH Port Forwarding

> **Note:** Just a command-line exercise. No terraform needed.

**The Problem:** You want to access a web server (port 80) on a remote machine, but the firewall only allows SSH (port 22).

**The Solution:** Use SSH Local Port Forwarding (`-L`) to tunnel port 80 traffic through your established SSH connection.

## Prerequisites
- SSH access to remote host (HostB)
- Service running on remote host (e.g., nginx on port 80)

## Objective
Use `ssh -L` to tunnel remote HTTP to your local machine (`http://localhost:2000`).

## How-to

### 1. Establish the Tunnel
Run this on your local machine:

```bash
ssh -L localhost:2000:localhost:80 user@HostB
```

**What this does:**
- Listens on local port `2000`
- Forwards traffic through the SSH tunnel to `HostB`
- Sends it to `localhost:80` (relative to HostB)

### 2. Access the Service
Open your local browser to:
`http://localhost:2000`

You're now viewing the remote web server, bypassing the firewall.

## Related Exercises
- [6 - SSH Agent Forwarding](./06-ssh-hopping.md) - Authenticating across hops
- [8 - X11 Forwarding](./08-x11-forwarding.md) - Forwarding GUI apps
