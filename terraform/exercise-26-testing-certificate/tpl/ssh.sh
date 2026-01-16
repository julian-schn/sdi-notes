#!/usr/bin/env bash
# SSH wrapper script
GEN_DIR=$(dirname "$0")/../gen
ssh -o UserKnownHostsFile="$GEN_DIR/known_hosts" ${devopsUsername}@${hostname} "$@"
