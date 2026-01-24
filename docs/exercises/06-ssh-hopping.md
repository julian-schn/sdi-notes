# 6 - SSH Agent Forwarding

> **Note:** This is a conceptual/command-line exercise. No terraform implementation required.

## Overview
SSH agent forwarding lets you use your local SSH keys to authenticate on remote hosts without copying your private keys there. When enabled (with ssh -A), the remote host can forward authentication requests back to your local SSH agent. You only actually authenticate with system "A" (Assuming host -> System A -> System B) which relays to system B.

## Prerequisites
- Local SSH agent running with loaded keys
- SSH access to intermediate (bastion) host
- SSH access to target host from bastion

## Objective
Use `ssh -A bastion` then `ssh target` so your local agent signs auth requests on the final host without copying keys anywhere.

## Implementation

### Why/When use it?
Use agent forwarding when you must "hop" through intermediate servers (e.g. workstation → bastion → internal host) and still want to authenticate using your local keys — securely, without storing keys on those intermediate systems.

### Usage
```bash
ssh -A bastion
```

Once connected to the bastion, you can SSH to the target system:
```bash
ssh target
```

Your local SSH agent will handle authentication for the target system without any keys being stored on the bastion host.

## Verification
1. Connect to bastion with agent forwarding: `ssh -A bastion`
2. From bastion, connect to target: `ssh target`
3. Connection should succeed without password prompt or key files on bastion

## Problems & Learnings

::: warning Common Issues
*This section will be filled in collaboratively. Common issues encountered during this exercise will be documented here.*
:::

::: tip Key Takeaways
*Key learnings and best practices from this exercise will be documented here.*
:::

## Related Exercises
- [16 - SSH Known Hosts](./16-ssh-known-hosts.md) - Managing SSH host keys for automated connections
