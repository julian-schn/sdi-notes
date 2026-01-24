# 12 - Journalctl

> **Note:** This is a conceptual/command-line exercise. No terraform implementation required.

## Overview
`journalctl` displays system logs collected by systemd's journald service. Unlike `/var/log/*.log` files, these logs are stored in a binary journal that keeps logs from all services — including SSH, kernel, authentication, etc.

## Prerequisites
- Systemd-based Linux distribution
- Basic understanding of system services

## Objective
Use `journalctl -f` to follow all systemd-managed logs live, or `journalctl -u service` for a specific unit.

## Implementation

### Viewing All Logs
Display all system logs:

```bash
journalctl
```

### Following Logs in Real Time
Watch logs as they are generated (similar to `tail -f`):

```bash
journalctl -f
```

### Filtering by Service Unit
View logs for a specific service:

```bash
journalctl -u nginx
```

Follow logs for a specific service:

```bash
journalctl -u ssh -f
```

### Additional Useful Options
Show logs since last boot:
```bash
journalctl -b
```

Show logs from a specific time range:
```bash
journalctl --since "2024-01-01" --until "2024-01-02"
```

Show kernel messages only:
```bash
journalctl -k
```

Show logs with high priority (errors and above):
```bash
journalctl -p err
```

## Verification
1. View all system logs: `journalctl`
2. Follow live logs: `journalctl -f`
3. In another terminal, restart a service: `sudo systemctl restart nginx`
4. Verify restart messages appear in journalctl output
5. Filter for specific service: `journalctl -u nginx`

## Problems & Learnings

::: warning Common Issues
*This section will be filled in collaboratively. Common issues encountered during this exercise will be documented here.*
:::

::: tip Key Takeaways
*Key learnings and best practices from this exercise will be documented here.*
:::

## Related Exercises
- [11 - Tail](./11-tail.md) - File-based log monitoring
- [14 - Nginx Automation](./14-nginx-automation.md) - Service that generates logs
