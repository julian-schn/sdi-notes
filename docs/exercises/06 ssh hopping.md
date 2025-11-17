# 6 - SSH Agent Forwarding
- SSH agent forwarding lets you use your local SSH keys to authenticate on remote hosts without copying your private keys there. When enabled (with ssh -A), the remote host can forward authentication requests back to your local SSH agent. You only actually authenticate with system "A" (Assuming host -> System A -> System B) which relays to system B

TLDR: Use `ssh -A bastion` then `ssh target` so your local agent signs auth requests on the final host without copying keys anywhere.

## Why/When use it?
- Use agent forwarding when you must “hop” through intermediate servers (e.g. workstation → bastion → internal host) and still want to authenticate using your local keys — securely, without storing keys on those intermediate systems.
