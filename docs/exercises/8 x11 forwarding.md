# 8 - x11 Forwarding
x11 Forwarding allows you to run a program with a GUI on remote machine and have it be displayed on your local machine. 

Given for remote host:
- Only allows ssh, runs nginx, x11 forwarding is to be used

1. Configure firewall on remote host (only open port 22)
    ```bash
    sudo ufw allow ssh
    sudo ufw deny 80
    sudo ufw deny 443
    ```
2. Install xauth on remote host
    ```bash
    sudo apt install xauth
    ```
3. Log in again with x11 forwarding
    ```bash
    ssh -Y user@hostA
    ```
4. Install Firefox on remote host and run, open a random website
    ```bash
    sudo apt install firefox-esr
    firefox &
    http://localhost
    ```