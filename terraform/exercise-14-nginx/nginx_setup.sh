#!/bin/bash
# Nginx setup script for Exercise 14

set -euo pipefail

apt-get update -y
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx

echo "Nginx installation completed successfully!"
