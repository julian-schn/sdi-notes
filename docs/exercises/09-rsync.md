# 9 - Directory transfer with rsync and ssh

With ``rsync`` you can synchronize directories between two machines. It only copies the differences (changed or new files), making it much faster than ``scp``.
When combined with SSH, it encrypts data in transit and uses SSH authentication.

TLDR: `rsync -avz -e ssh src/ user@host:dest/` copies only deltas over SSH; rerun the same command to sync changes both ways as needed.

- Install with 
    ```bash
    sudo apt install rsync
    ```
1. Copy local directory to remote host
    ```bash
    rsync -avz -e ssh ~/projects/localdir/ user@remotehost:~/backup/
    ```
2. Run again
    ```bash
    rsync -avz -e ssh ~/projects/localdir/ user@remotehost:~/backup/
    ```
3. rsync compares directories and syncs possible changes. Here:
    ```bash
    sending incremental file list

    sent 123 bytes  received 45 bytes  total size 0
    ```
4. Changes on remote host
    - ssh into remote host, add new file into ``/backup/localdir/```
    - log out and run above command on local machine again
    - rsync will force sync both directories

5. Reverse direction
    ```bash
    rsync -avz -e ssh user@remotehost:~/backup/dir/ ~/projects/dir/
    ```
