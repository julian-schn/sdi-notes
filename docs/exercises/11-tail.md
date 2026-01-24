# 11 - Tail -f

> **Note:** This is a conceptual/command-line exercise. No terraform implementation required.

## Overview
`tail` shows the last lines of a file. Adding the `-f` flag makes it keep running, continuously showing new lines as they're added to the file - perfect for monitoring log files in real time.

## Prerequisites
- Access to log files or any text file that receives updates
- Basic understanding of Linux command line

## Objective
Use `tail -f logfile` to stream new log lines in real time; hit Ctrl+C to stop.

## Implementation

### Basic Usage
View the last 10 lines of a file:

```bash
tail filename
```

### Following File Updates
Monitor a file for new content in real time:

```bash
tail -f logfile
```

The command will continue running and display new lines as they are appended to the file.

### Stopping the Monitor
Press `Ctrl+C` to stop the tail command and return to the shell prompt.

### Common Use Cases
Monitor system logs:
```bash
tail -f /var/log/syslog
```

Monitor web server access logs:
```bash
tail -f /var/log/nginx/access.log
```

Monitor application logs:
```bash
tail -f /var/log/application.log
```

## Verification
1. Create a test file: `echo "Line 1" > testfile.txt`
2. Start monitoring: `tail -f testfile.txt`
3. In another terminal, append to the file: `echo "Line 2" >> testfile.txt`
4. Verify the new line appears in the tail output
5. Stop monitoring with `Ctrl+C`

## Problems & Learnings

::: warning Common Issues
*This section will be filled in collaboratively. Common issues encountered during this exercise will be documented here.*
:::

::: tip Key Takeaways
*Key learnings and best practices from this exercise will be documented here.*
:::

## Related Exercises
- [12 - Journalctl](./12-journalctl.md) - System-wide log monitoring with systemd
- [10 - Index Based Search](./10-index-based-search.md) - File search utilities
