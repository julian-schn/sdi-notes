# SSH Port Forwarding
To bypass a firewall that filters everything besides ssh on port 22, you can enable ssh port forwarding if you want to, for example, access an nginx serer using HTTP(S).
This way you can tunnel port 80 traffic through 22, by doing the following on your system with the firewall (HostB):
```bash
ssh -L localhost:2000:www.hdm-stuttgart.de:80 HostB
```
you can now access nginx on port ``localhost:2000``