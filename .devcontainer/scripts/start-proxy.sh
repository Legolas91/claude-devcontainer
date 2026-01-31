#!/bin/bash
# Démarre le proxy Claude Code en arrière-plan

PROXY_BIN="/usr/local/bin/claude-code-proxy"
LOG_FILE="/tmp/claude-code-proxy.log"
PID_FILE="/tmp/claude-code-proxy.pid"

# Vérifier si déjà en cours d'exécution
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        echo "✅ Proxy déjà en cours d'exécution (PID: $OLD_PID)"
        exit 0
    else
        rm -f "$PID_FILE"
    fi
fi

# Vérifier via health check
if curl -s http://localhost:8082/ > /dev/null 2>&1; then
    echo "✅ Proxy déjà en cours d'exécution"
    exit 0
fi

# Vérifier que le binaire existe
if [ ! -f "$PROXY_BIN" ]; then
    echo "❌ Binaire du proxy non trouvé: $PROXY_BIN"
    exit 1
fi

echo "🚀 Démarrage du proxy..."

# Lancer en background avec nohup
nohup "$PROXY_BIN" -s > "$LOG_FILE" 2>&1 &
echo $! > "$PID_FILE"

# Attendre que le proxy soit prêt
for i in {1..10}; do
    sleep 1
    if curl -s http://localhost:8082/ > /dev/null 2>&1; then
        echo "✅ Proxy démarré sur http://localhost:8082"
        echo "   PID: $(cat $PID_FILE)"
        echo "   Logs: $LOG_FILE"
        exit 0
    fi
done

echo "❌ Le proxy n'a pas démarré correctement"
echo "   Vérifiez les logs: cat $LOG_FILE"
cat "$LOG_FILE"
exit 1
