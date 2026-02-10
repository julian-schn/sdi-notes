# 8 - X11 Forwarding

> **Note:** Just a command-line exercise. No terraform needed.

**The Problem:** You are working on a remote server (headless), but you need to run a GUI application like an IDE or web browser and see it on your local screen.

**The Solution:** SSH X11 Forwarding (`-Y`) streams the application's graphical window from the server to your local display.

## Prerequisites
- SSH access to remote host
- X11 server running locally (XQuartz on Mac, Xorg/Wayland on Linux, WSLg/Xming on Windows)
- `xauth` installed on remote host

## Objective
Launch a remote GUI app (e.g., `firefox`) and interact with it locally.

## How-to

### 1. Install xauth (Remote)
The remote server needs `xauth` to handle the display authorization:

```bash
sudo apt install xauth
```

### 2. Connect with Forwarding
Connect with the `-Y` flag (Trusted X11 forwarding):

```bash
ssh -Y user@host
```

### 3. Launch App
Run the GUI app from the SSH terminal. Adding `&` keeps your terminal usable:

```bash
firefox &
```

The window should pop up on your local machine.

## Related Exercises
- [7 - SSH Port Forwarding](./07-ssh-port-forwarding.md) - Tunneling other protocols
