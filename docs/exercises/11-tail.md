# 11 - Tail -f

> **Note:** Just a command-line exercise.

**The Problem:** You need to see new log entries as they happen in real-time, but opening the file over and over is tedious.

**The Solution:** `tail -f` ("follow") keeps the file open and prints new lines as they are written.

## Objective
Watch a log file in real-time.

## How-to

### Follow a File
```bash
tail -f /var/log/syslog
```

Press `Ctrl+C` to stop.

### Use Cases
- Debugging a crashing server: `tail -f /var/log/nginx/error.log`
- Watching application output: `tail -f app.log`

## Related Exercises
- [12 - Journalctl](./12-journalctl.md) - Systemd logs (the modern way)
