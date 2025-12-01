#!/usr/bin/env bash
# Test script to verify .env is being loaded correctly by Terraform

set -e

echo "===== Testing .env Variable Loading ====="
echo ""

# Source the .env file
cd "$(dirname "$0")"
if [ ! -f .env ]; then
    echo "❌ ERROR: .env file not found!"
    echo "Please copy .env.example to .env and configure it"
    exit 1
fi

echo "✅ Sourcing .env file..."
source .env

echo ""
echo "🔍 Checking environment variables:"
echo "-----------------------------------"

# Check required variables
if [ -n "$HCLOUD_TOKEN" ]; then
    echo "✅ HCLOUD_TOKEN is set (${#HCLOUD_TOKEN} characters)"
else
    echo "❌ HCLOUD_TOKEN is NOT set"
fi

if [ -n "$TF_VAR_ssh_public_key" ]; then
    echo "✅ TF_VAR_ssh_public_key is set"
else
    echo "❌ TF_VAR_ssh_public_key is NOT set"
fi

# Check optional variables
declare -a optional_vars=(
    "TF_VAR_server_type"
    "TF_VAR_server_image"
    "TF_VAR_location"
    "TF_VAR_server_name"
    "TF_VAR_server_base_name"
    "TF_VAR_devops_username"
    "TF_VAR_project"
    "TF_VAR_environment"
)

for var in "${optional_vars[@]}"; do
    if [ -n "${!var}" ]; then
        echo "✅ $var = ${!var}"
    else
        echo "⚠️  $var not set (will use default)"
    fi
done

echo ""
echo "🧪 Testing Terraform variable detection in base exercise:"
echo "---------------------------------------------------------"

cd base

# Check if terraform can see the variables
terraform_output=$(terraform console 2>&1 <<EOF
var.server_type
var.location
var.server_image
EOF
)

if echo "$terraform_output" | grep -q "Error"; then
    echo "❌ Terraform console test failed"
    echo "$terraform_output"
else
    echo "✅ Terraform can access variables from environment!"
    echo ""
    echo "Values Terraform sees:"
    echo "$terraform_output" | while read line; do
        echo "  $line"
    done
fi

echo ""
echo "===== Test Complete ====="
