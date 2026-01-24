# 7 - SSH Port Forwarding

> **Note:** This is a conceptual/command-line exercise. No terraform implementation required.

## Overview
To bypass a firewall that filters everything besides ssh on port 22, you can enable ssh port forwarding if you want to, for example, access an nginx server using HTTP(S). This way you can tunnel port 80 traffic through port 22.

## Prerequisites
- SSH access to remote host (HostB)
- Firewall allowing SSH (port 22) but blocking HTTP (port 80)
- Service running on remote host that you want to access (e.g., nginx on port 80)

## Objective
Use `ssh -L localhost:2000:site:80 HostB` to tunnel remote HTTP over your SSH connection so you can browse via `http://localhost:2000`.

## Implementation

### Setting up Local Port Forwarding
On your local system, establish an SSH connection with local port forwarding:

```bash
ssh -L localhost:2000:www.hdm-stuttgart.de:80 HostB
```

This command forwards local port 2000 to port 80 on the target site through HostB.

### Accessing the Service
You can now access nginx on your local machine at:
```bash
http://localhost:2000
```

The traffic will be tunneled through the SSH connection on port 22, bypassing the firewall restrictions.

## Verification
1. Establish SSH connection with port forwarding: `ssh -L localhost:2000:www.hdm-stuttgart.de:80 HostB`
2. Open browser and navigate to `http://localhost:2000`
3. Verify that you can access the remote service through the tunnel

## Problems & Learnings

::: warning Common Issues
*This section will be filled in collaboratively. Common issues encountered during this exercise will be documented here.*
:::

::: tip Key Takeaways
*Key learnings and best practices from this exercise will be documented here.*
:::

## Related Exercises
- [6 - SSH Agent Forwarding](./06-ssh-hopping.md) - Using SSH agent for authentication across hops
- [8 - X11 Forwarding](./08-x11-forwarding.md) - Forwarding GUI applications over SSH
