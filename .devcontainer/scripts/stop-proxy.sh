#!/bin/bash
# Arrête le proxy Claude Code

PID_FILE="/tmp/claude-code-proxy.pid"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        echo "🛑 Arrêt du proxy (PID: $PID)..."
        kill "$PID"
        rm -f "$PID_FILE"
        echo "✅ Proxy arrêté"
    else
        echo "⚠️  Proxy non actif (PID obsolète)"
        rm -f "$PID_FILE"
    fi
else
    # Essayer de tuer par nom de processus
    pkill -f "claude-code-proxy" 2>/dev/null && echo "✅ Proxy arrêté" || echo "⚠️  Proxy non actif"
fi
