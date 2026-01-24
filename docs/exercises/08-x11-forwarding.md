# 8 - X11 Forwarding

> **Note:** This is a conceptual/command-line exercise. No terraform implementation required.

## Overview
X11 Forwarding allows you to run a program with a GUI on a remote machine and have it displayed on your local machine.

## Prerequisites
- SSH access to remote host
- X11 server running on local machine
- xauth installed on remote host
- Firewall configured to only allow SSH (port 22)

## Objective
Use `ssh -Y user@host` to forward X11 so GUI apps launched remotely (e.g., `firefox &`) render on your local display; ensure xauth installed and firewall only allows SSH.

## Implementation

### Step 1: Configure Firewall on Remote Host
Ensure only SSH is allowed (port 22 open, HTTP/HTTPS blocked):

```bash
sudo ufw allow ssh
sudo ufw deny 80
sudo ufw deny 443
```

### Step 2: Install xauth on Remote Host
Install the xauth package required for X11 forwarding:

```bash
sudo apt install xauth
```

### Step 3: Connect with X11 Forwarding
Log in to the remote host with X11 forwarding enabled:

```bash
ssh -Y user@hostA
```

The `-Y` flag enables trusted X11 forwarding.

### Step 4: Install and Run GUI Application
Install Firefox on the remote host and run it:

```bash
sudo apt install firefox-esr
firefox &
```

Open a website to verify:
```bash
http://localhost
```

The Firefox window should appear on your local display, even though the application is running on the remote host.

## Verification
1. Connect with X11 forwarding: `ssh -Y user@hostA`
2. Run a GUI application: `firefox &`
3. Verify that the application window appears on your local display
4. Confirm only port 22 is open on the firewall: `sudo ufw status`

## Problems & Learnings

::: warning Common Issues
*This section will be filled in collaboratively. Common issues encountered during this exercise will be documented here.*
:::

::: tip Key Takeaways
*Key learnings and best practices from this exercise will be documented here.*
:::

## Related Exercises
- [7 - SSH Port Forwarding](./07-ssh-port-forwarding.md) - Tunneling other protocols over SSH
- [14 - Nginx Automation](./14-nginx-automation.md) - Automated web server setup
