#!/usr/bin/env python3
import json
import os
import sys

# Constants
TF_OUTPUT_FILE = "terraform_output.json"
INVENTORY_FILE = "Inventory.ini"

# Check Terraform output file exists
if not os.path.exists(TF_OUTPUT_FILE):
    print(f"ERROR: {TF_OUTPUT_FILE} not found", file=sys.stderr)
    sys.exit(1)

# Load Terraform outputs
with open(TF_OUTPUT_FILE, "r") as f:
    try:
        tf_output = json.load(f)
    except json.JSONDecodeError as e:
        print(f"ERROR: Failed to parse {TF_OUTPUT_FILE} - {str(e)}", file=sys.stderr)
        sys.exit(1)

# Parse outputs into a dictionary
outputs = {item["attributes"]["name"]: item["attributes"]["value"] for item in tf_output.get("data", [])}

# Extract VM IPs
linux_ips = outputs.get("linux_vm_ips", [])
windows_ips = outputs.get("windows_vm_ips", [])

# Environment variables (with fallbacks)
ssh_key = os.getenv("SSH_KEY_PATH", os.path.expanduser("~/.ssh/id_rsa"))
linux_user = os.getenv("LINUX_USER", "")
win_user = os.getenv("WIN_USER", "")
win_pass = os.getenv("WIN_PASS", "")

# Build inventory content
lines = []

# Linux group
if linux_ips:
    lines.append("[linux]")
    for ip in linux_ips:
        lines.append(f"{ip} ansible_user={linux_user} "
                     f"ansible_ssh_private_key_file={ssh_key} "
                     f"ansible_connection=ssh "
                     f"ansible_ssh_common_args='-o StrictHostKeyChecking=no'")

# Windows group
if windows_ips:
    lines.append("\n[windows]")
    for ip in windows_ips:
        lines.append(f"{ip} ansible_user={win_user} "
                     f"ansible_password={win_pass} "
                     f"ansible_connection=winrm "
                     f"ansible_port=5986 "
                     f"ansible_winrm_transport=basic "
                     f"ansible_winrm_server_cert_validation=ignore")

# Write to inventory.ini
with open(INVENTORY_FILE, "w") as f:
    f.write("\n".join(lines) + "\n")

print(f"Ansible inventory written to: {INVENTORY_FILE}")
