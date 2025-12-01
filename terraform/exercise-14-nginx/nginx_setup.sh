#!/bin/bash
# Nginx setup script for Exercise 14
# This script runs automatically when the server is created

set -euo pipefail

# Update package list
apt-get update -y

# Install Nginx web server
apt-get install -y nginx

# Start Nginx immediately
systemctl start nginx

# Enable Nginx to start automatically on boot
systemctl enable nginx

echo "Nginx installation completed successfully!"
