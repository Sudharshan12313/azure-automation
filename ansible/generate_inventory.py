#!/usr/bin/env python3
import json
import os
import sys

# Load terraform output
try:
    with open("terraform_output.json", "r") as f:
        tf_output = json.load(f)
except FileNotFoundError:
    print("ERROR: terraform_output.json not found", file=sys.stderr)
    sys.exit(1)

# Fetch grouped IPs
linux_ips = tf_output.get("linux_vm_ips", {}).get("value", [])
windows_ips = tf_output.get("windows_vm_ips", {}).get("value", [])

# Optional debug (print IPs)
# print("Linux IPs:", linux_ips)
# print("Windows IPs:", windows_ips)

# Environment variables (set in GitHub Actions or local env)
ssh_key = os.getenv("SSH_KEY_PATH", "~/.ssh/id_rsa")
linux_user = os.getenv("LINUX_USER", "azureuser")
win_user = os.getenv("WIN_USER", "azureuser")
win_pass = os.getenv("WIN_PASS", "ChangeThis123!")  # Set securely in GH secrets

# Build inventory
inventory = {
    "all": {
        "children": ["linux", "windows"]
    },
    "linux": {
        "hosts": linux_ips,
        "vars": {
            "ansible_user": linux_user,
            "ansible_ssh_private_key_file": ssh_key
        }
    },
    "windows": {
        "hosts": windows_ips,
        "vars": {
            "ansible_user": win_user,
            "ansible_password": win_pass,
            "ansible_connection": "winrm",
            "ansible_winrm_transport": "basic",
            "ansible_winrm_server_cert_validation": "ignore"
        }
    },
    "_meta": {
        "hostvars": {}
    }
}

# Output JSON inventory to stdout
print(json.dumps(inventory, indent=2))
