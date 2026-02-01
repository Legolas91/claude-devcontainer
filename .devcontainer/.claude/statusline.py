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
from datetime import datetime, timedelta

# fcntl only available on Unix - not needed on Windows
if sys.platform != 'win32':
    import fcntl
else:
    fcntl = None

# Configuration: Budgets calibrés sur les quotas Anthropic (Plan Max 5x)
# NOTE: Ces valeurs sont approximatives - Anthropic calcule en tokens, pas en $
# Ajustez ces valeurs si les % ne correspondent pas à votre dashboard
SESSION_BUDGET_USD = 9.9     # Budget par session calibré pour correspondre à /config > Usage
WEEKLY_BUDGET_USD = 108.0    # Budget hebdomadaire calculé depuis /config > Usage (18% = $19.43)

# Pour correspondre aux % Anthropic, utilisez previous_sessions dans usage_tracking.json
# comme baseline manuelle (sera ajouté au total hebdomadaire)

# Tracking file path
TRACKING_FILE = Path.home() / ".claude" / "usage_tracking.json"


def get_week_start():
    """Get the Monday of the current week as ISO date string."""
    today = datetime.now().date()
    monday = today - timedelta(days=today.weekday())
    return monday.isoformat()


def load_tracking_data():
    """Load tracking data from file, return empty dict if not exists."""
    try:
        if TRACKING_FILE.exists():
            with open(TRACKING_FILE, 'r') as f:
                return json.load(f)
    except (json.JSONDecodeError, IOError):
        pass
    return {}


def save_tracking_data(data):
    """Save tracking data to file with file locking for safety."""
    try:
        TRACKING_FILE.parent.mkdir(parents=True, exist_ok=True)
        with open(TRACKING_FILE, 'w') as f:
            if sys.platform != 'win32':
                fcntl.flock(f.fileno(), fcntl.LOCK_EX)
            json.dump(data, f, indent=2)
            if sys.platform != 'win32':
                fcntl.flock(f.fileno(), fcntl.LOCK_UN)
    except IOError:
        pass


def update_weekly_cost(session_id, session_cost):
    """Update the weekly cost tracking with current session cost."""
    tracking = load_tracking_data()
    current_week = get_week_start()

    # Reset if new week (but preserve manual baseline if set)
    if tracking.get("week_start") != current_week:
        # Keep previous_sessions as baseline if it exists
        baseline = tracking.get("sessions", {}).get("previous_sessions", 0)
        tracking = {
            "week_start": current_week,
            "sessions": {"previous_sessions": baseline} if baseline else {}
        }

    # Update session cost (each session tracked separately to avoid double counting)
    if "sessions" not in tracking:
        tracking["sessions"] = {}

    # Only update if this is a real session ID (not the preserved baseline)
    if session_id != "previous_sessions":
        tracking["sessions"][session_id] = session_cost

    # Calculate total weekly cost
    weekly_total = sum(tracking["sessions"].values())

    save_tracking_data(tracking)
    return weekly_total


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

        # Get session ID for tracking - try multiple sources for a stable ID
        session_id = (
            data.get("conversation_id") or
            data.get("session_id") or
            data.get("session", {}).get("id") or
            os.environ.get("CLAUDE_SESSION_ID") or
            # Fallback: use project + date as stable ID (one entry per project per day)
            f"{project_name}_{datetime.now().strftime('%Y%m%d')}"
        )

        # Priority 1: Use real API cost and usage data from Claude Code if available
        session_cost = 0.0
        weekly_cost = 0.0
        session_percent = None
        weekly_percent = None

        # Try to get real API cost data
        if data.get("cost"):
            cost_data = data["cost"]
            if cost_data.get("total_cost_usd") is not None:
                session_cost = cost_data["total_cost_usd"]
            if cost_data.get("weekly_cost_usd") is not None:
                weekly_cost = cost_data["weekly_cost_usd"]
            # Get real API usage percentages if available
            if cost_data.get("session_usage_percent") is not None:
                session_percent = cost_data["session_usage_percent"]
            if cost_data.get("weekly_usage_percent") is not None:
                weekly_percent = cost_data["weekly_usage_percent"]

        # Priority 2: Check for usage data in other possible locations
        if data.get("usage"):
            if session_percent is None:
                session_percent = data["usage"].get("session_percent") or data["usage"].get("session_usage_percent")
            if weekly_percent is None:
                weekly_percent = data["usage"].get("week_percent") or data["usage"].get("weekly_usage_percent")

        if data.get("limits"):
            if session_percent is None:
                session_percent = data["limits"].get("session_percent")
            if weekly_percent is None:
                weekly_percent = data["limits"].get("week_percent")

        # Priority 3: Add global session baseline to session cost
        # This allows tracking the total Anthropic session cost across all conversations
        tracking = load_tracking_data()
        session_baseline = tracking.get("global_session", {}).get("baseline_cost", 0.0)
        total_session_cost = session_cost + session_baseline

        # Priority 4: Update/calculate weekly tracking if no API data available
        if weekly_cost == 0.0:
            weekly_cost = update_weekly_cost(session_id, session_cost)

        # Priority 5: Fallback to calculated percentages only if no real data available
        if session_percent is None:
            session_percent = (total_session_cost / SESSION_BUDGET_USD) * 100 if SESSION_BUDGET_USD > 0 else 0
        if weekly_percent is None:
            weekly_percent = (weekly_cost / WEEKLY_BUDGET_USD) * 100 if WEEKLY_BUDGET_USD > 0 else 0

        # Get git branch from JSON data
        git_branch = ""
        if data.get("workspace", {}).get("git_branch"):
            git_branch = data["workspace"]["git_branch"]
        elif data.get("workspace", {}).get("git", {}).get("branch"):
            git_branch = data["workspace"]["git"]["branch"]

        # Get hostname
        hostname = os.environ.get('COMPUTERNAME', os.environ.get('HOSTNAME', 'localhost'))

        # Format output
        branch_info = f" (br: {git_branch})" if git_branch else ""
        output = f"{hostname} | {project_name}{branch_info} | {model} | Ctx: {context_percent}%"

        # Write output without newline
        print(output, end='')

    except Exception as e:
        # Fallback: display basic info if JSON parsing fails
        print(f"{os.environ.get('COMPUTERNAME', 'localhost')} | claude", end='')

if __name__ == "__main__":
    main()
