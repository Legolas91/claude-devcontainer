#!/usr/bin/env python3
"""
StatusLine script for Claude Code
Reads JSON from stdin and displays a formatted prompt
Format: HOSTNAME | ProjectName (br: branch) | Model | Ctx: XX%
"""

import json
import sys
import os
from pathlib import Path


def main():
    try:
        # Read JSON input from stdin
        json_input = sys.stdin.read()
        data = json.loads(json_input)

        # Debug mode: save JSON to file if DEBUG env var is set
        if os.environ.get('STATUSLINE_DEBUG'):
            debug_file = Path.home() / ".claude" / "statusline_debug.json"
            with open(debug_file, 'w') as f:
                json.dump(data, f, indent=2)

        # Extract project name from current directory
        current_dir = data.get("workspace", {}).get("current_dir", "~")
        project_name = Path(current_dir).name

        # Get model name
        model = "sonnet"
        if data.get("model", {}).get("display_name"):
            model = data["model"]["display_name"]
        elif data.get("model", {}).get("id"):
            model_id = data["model"]["id"]
            if "sonnet" in model_id:
                model = "Sonnet 4.5"
            elif "opus" in model_id:
                model = "Opus 4.5"
            elif "haiku" in model_id:
                model = "Haiku"

        # Get context usage percentage
        context_percent = 0
        if data.get("context_window", {}).get("used_percentage"):
            context_percent = round(data["context_window"]["used_percentage"])

        # Get git branch from JSON data
        git_branch = ""
        if data.get("workspace", {}).get("git_branch"):
            git_branch = data["workspace"]["git_branch"]
        elif data.get("workspace", {}).get("git", {}).get("branch"):
            git_branch = data["workspace"]["git"]["branch"]

        # Get hostname with smart devcontainer detection
        hostname = os.environ.get('COMPUTERNAME', os.environ.get('HOSTNAME', 'localhost'))
        container_id = None

        # Try to read real container hostname from /etc/hostname (works in Linux containers)
        try:
            with open('/etc/hostname', 'r') as f:
                real_hostname = f.read().strip()
                # Check if it's a container ID (hex string >= 12 chars)
                if len(real_hostname) >= 12 and all(c in '0123456789abcdef' for c in real_hostname):
                    container_id = real_hostname[:12]  # Use short ID (12 chars)
        except (FileNotFoundError, IOError):
            pass

        # Priority 1: Custom hostname for devcontainers
        if os.environ.get('DEVCONTAINER_HOSTNAME'):
            hostname = os.environ.get('DEVCONTAINER_HOSTNAME')
        # Priority 2: Detect container ID (hex string >= 12 chars) and replace with friendly name
        elif len(hostname) >= 12 and all(c in '0123456789abcdef' for c in hostname):
            if not container_id:
                container_id = hostname[:12]
            hostname = "devcontainer"

        # Add container ID suffix if in Docker
        if container_id:
            hostname = f"{hostname} (CID: {container_id})"

        # Format output
        branch_info = f" (br: {git_branch})" if git_branch else ""
        output = f"{hostname} | {project_name}{branch_info} | {model} | Ctx: {context_percent}%"

        # Write output without newline
        print(output, end='')

    except Exception as e:
        # Fallback: display basic info if JSON parsing fails
        hostname = os.environ.get('DEVCONTAINER_HOSTNAME') or os.environ.get('COMPUTERNAME', 'localhost')
        print(f"{hostname} | claude", end='')

if __name__ == "__main__":
    main()
