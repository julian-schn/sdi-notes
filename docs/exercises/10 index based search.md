# 10 - Index based search
TLDR: install `plocate`, run `updatedb` once, then `locate <pattern>` for instant filename search; rerun `updatedb` after file changes.

1. install ``plocate``
    ```bash
    sudo apt install plocate
    ```
2. build index
    ```bash
    sudo updatedb
    ```
    builds a db at ``/var/lib/plocate/plocate.db``
3. seach files
    ```bash
    locate aptitude
    ```
4. run ``updatedb`` again when adding new/deleting files
