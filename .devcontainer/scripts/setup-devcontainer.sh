#!/bin/bash
# Setup script for Claude DevContainer

set -e

echo "🚀 Claude DevContainer setup..."
echo ""
echo "📦 Outils disponibles:"
echo "  - Node.js $(node --version)"
echo "  - npm $(npm --version)"
echo "  - Claude Code $(claude --version 2>&1 | head -1)"
echo ""
echo "🔧 Commandes proxy:"
echo "  - start-proxy : Démarrer le proxy"
echo "  - stop-proxy  : Arrêter le proxy"
echo "  - test-proxy  : Tester le proxy"
echo ""
echo "✅ Setup terminé"
