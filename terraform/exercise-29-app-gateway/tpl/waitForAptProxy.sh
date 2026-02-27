#!/bin/bash
# Wait for apt-cacher-ng service to be ready
# This script is executed on the gateway host by Terraform provisioner
# AI-assisted: nc polling loop with attempt counter and diagnostics on failure

echo "Waiting for apt-cacher-ng on ${interface}:3142..."

max_attempts=60
attempt=0
sleep_interval=5

while ! nc -z ${interface} 3142; do
  attempt=$((attempt + 1))

  if [ $attempt -ge $max_attempts ]; then
    echo "ERROR: apt-cacher-ng service did not become ready after $max_attempts attempts ($(($max_attempts * $${sleep_interval})) seconds total)"
    systemctl status apt-cacher-ng --no-pager || true
    journalctl -u apt-cacher-ng -n 50 --no-pager || true
    exit 1
  fi

  echo "Attempt $attempt/$max_attempts: apt-cacher-ng not yet ready, waiting $${sleep_interval} seconds..."
  sleep $sleep_interval
done

echo "apt-cacher-ng ready on ${interface}:3142"

exit 0
