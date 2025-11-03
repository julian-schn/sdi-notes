# 9 - Directory transfer with rsync and ssh

With ``rsync`` you can synchronize directories between two machines. It only copies the differences (changed or new files), making it much faster than ``scp``.
When combined with SSH, it encrypts data in transit and uses SSH authentication.

- Install with 

```bash
sudo apt install rsync
```

1. Copy local directory to remote host

```bash
rsync -avz -e ssh ~/projects/mylocaldir/ user@remotehost:~/backup/
```

2. Run again

```bash
rsync -avz -e ssh ~/projects/mylocaldir/ user@remotehost:~/backup/
```

3. rsync compares directories and syncs possible changes. Here:

```bash
sending incremental file list

sent 123 bytes  received 45 bytes  total size 0
```

4. Changes on remote host
- ssh into remote host, add new file into ``/backup/mylocaldir/```
- log out and run above command on local machine again
- rsync will force sync both directories
5. Reverse direction

```bash
rsync -avz -e ssh user@remotehost:~/backup/mydir/ ~/projects/mydir/
```