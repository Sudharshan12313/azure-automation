#!/usr/bin/env python3
import json
import os
import sys

# Load terraform output file
TF_OUTPUT_FILE = "terraform_output.json"

if not os.path.exists(TF_OUTPUT_FILE):
    print(f"ERROR: {TF_OUTPUT_FILE} not found", file=sys.stderr)
    sys.exit(1)

with open(TF_OUTPUT_FILE, "r") as f:
    tf_output = json.load(f)

# Extract IPs from Terraform outputs
linux_ips = tf_output.get("linux_vm_ips", {}).get("value", [])
windows_ips = tf_output.get("windows_vm_ips", {}).get("value", [])

# Load environment variables or use defaults
ssh_key = os.getenv("SSH_KEY_PATH", os.path.expanduser("~/.ssh/id_rsa"))
linux_user = os.getenv("LINUX_USER", "azureuser")
win_user = os.getenv("WIN_USER", "azureuser")
win_pass = os.getenv("WIN_PASS", "ChangeThis123!")  # Store securely in CI

# Construct dynamic inventory structure
inventory = {
    "all": {
        "children": ["linux", "windows"]
    },
    "linux": {
        "hosts": linux_ips,
        "vars": {
            "ansible_user": linux_user,
            "ansible_ssh_private_key_file": ssh_key,
            "ansible_connection": "ssh",
            "ansible_ssh_common_args": "-o StrictHostKeyChecking=no"
        }
    },
    "windows": {
        "hosts": windows_ips,
        "vars": {
            "ansible_user": win_user,
            "ansible_password": win_pass,
            "ansible_connection": "winrm",
            "ansible_port": 5986,
            "ansible_winrm_transport": "basic",
            "ansible_winrm_server_cert_validation": "ignore"
        }
    },
    "_meta": {
        "hostvars": {}
    }
}

# Print inventory JSON to stdout (used by Ansible)
print(json.dumps(inventory, indent=2))
