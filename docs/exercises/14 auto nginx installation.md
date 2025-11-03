# 14 - Automatic Nginx installation 
1. create a ``nginx_setup-sh``, If it runs successfully and Nginx starts (``systemctl`` status ``nginx`` shows it active), you know your script is good.
```bash
#!/bin/bash
# Update package list
apt update -y

# Install Nginx web server
apt install -y nginx

# Start Nginx immediately
systemctl start nginx

# Enable Nginx to start automatically on boot
systemctl enable nginx
```
2. integrate into terraform
```hcl
resource "hcloud_server" "helloServer" {
  name        = "nginx-server"
  server_type = "cx11"
  image       = "ubuntu-22.04"
  location    = "hel1"
  ssh_keys    = [hcloud_ssh_key.mykey.id]

  user_data = file("nginx_setup.sh")
}
```
3. ``terraform apply``, very with ``systemctl status nginx``