# 12 - ``journalctl``
- ``journalctl`` displays system logs collected by systemd’s journald service.
Unlike ``/var/log/*.log`` files, these logs are stored in a binary journal that keeps logs from all services — including SSH, kernel, authentication, etc.
- ``tail -f`` just watches a specific text log file
- ``journalctl -f`` watches systemd’s central log system (includes all services, structured, searchable).


