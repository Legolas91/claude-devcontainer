#!/bin/bash
# Setup script for Claude DevContainer

set -e

echo "🚀 Claude DevContainer setup..."

# ==============================================================================
# Install bash aliases
# ==============================================================================
if [ -f /workspace/claude-devcontainer/.devcontainer/.bash_aliases ]; then
    echo "📝 Installation des alias bash..."
    cp /workspace/claude-devcontainer/.devcontainer/.bash_aliases ~/.bash_aliases

    # Add source to .bashrc if not already present
    if ! grep -q "source ~/.bash_aliases" ~/.bashrc; then
        echo "" >> ~/.bashrc
        echo "# Source custom aliases" >> ~/.bashrc
        echo "if [ -f ~/.bash_aliases ]; then" >> ~/.bashrc
        echo "    source ~/.bash_aliases" >> ~/.bashrc
        echo "fi" >> ~/.bashrc
    fi
    echo "✅ Alias bash installés"
fi

# ==============================================================================
# Auto-save Claude config on shell exit
# ==============================================================================
if ! grep -q "claude.json backup trap" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Auto-save Claude config to volume on exit" >> ~/.bashrc
    echo "# claude.json backup trap" >> ~/.bashrc
    echo 'trap '\''if [ -f /root/.claude.json ]; then cp /root/.claude.json /root/.claude/claude.json 2>/dev/null || true; fi'\'' EXIT' >> ~/.bashrc
    echo "✅ Sauvegarde automatique configurée"
fi

# ==============================================================================
# Configure Claude CLI - Restore config from volume
# ==============================================================================
echo "🔧 Configuration Claude CLI..."

# If no config in volume, use template
if [ ! -f /root/.claude/claude.json ]; then
    if [ -f /root/.claude/claude.json.template ]; then
        echo "📋 Utilisation du template de configuration..."
        cp /root/.claude/claude.json.template /root/.claude/claude.json
    fi
fi

# Always restore config from volume to /root (overwrites symlink if exists)
if [ -f /root/.claude/claude.json ]; then
    echo "📥 Restauration de la configuration depuis le volume..."
    cp /root/.claude/claude.json /root/.claude.json
    echo "✅ Configuration restaurée"
else
    echo "⚠️  Aucune configuration trouvée - l'authentification sera demandée"
fi

# ==============================================================================
# Display info
# ==============================================================================
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
