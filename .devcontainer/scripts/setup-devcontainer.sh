#!/bin/bash
# Setup script for Claude DevContainer

set -e

echo "🚀 Claude DevContainer setup..."

# ==============================================================================
# Fix permissions for mounted volume
# ==============================================================================
sudo chown -R claude-dev:claude-dev /home/claude-dev/.claude 2>/dev/null || true
sudo chmod -R u+w /home/claude-dev/.claude 2>/dev/null || true

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
    # Add source to .zshrc as well
    if [ -f ~/.zshrc ] && ! grep -q "source ~/.bash_aliases" ~/.zshrc; then
        echo "" >> ~/.zshrc
        echo "# Source custom aliases" >> ~/.zshrc
        echo "if [ -f ~/.bash_aliases ]; then" >> ~/.zshrc
        echo "    source ~/.bash_aliases" >> ~/.zshrc
        echo "fi" >> ~/.zshrc
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
    echo 'trap '\''if [ -f /home/claude-dev/.claude.json ]; then cp /home/claude-dev/.claude.json /home/claude-dev/.claude/claude.json 2>/dev/null || true; fi'\'' EXIT' >> ~/.bashrc
    echo "✅ Sauvegarde automatique configurée"
fi

# ==============================================================================
# Configure Claude CLI - Restore config from volume
# ==============================================================================
echo "🔧 Configuration Claude CLI..."

# If no config in volume, use template
if [ ! -f /home/claude-dev/.claude/claude.json ]; then
    if [ -f /home/claude-dev/.claude/claude.json.template ]; then
        echo "📋 Utilisation du template de configuration..."
        cp /home/claude-dev/.claude/claude.json.template /home/claude-dev/.claude/claude.json
    fi
fi

# Always restore config from volume to /home/claude-dev (overwrites symlink if exists)
if [ -f /home/claude-dev/.claude/claude.json ]; then
    echo "📥 Restauration de la configuration depuis le volume..."
    cp /home/claude-dev/.claude/claude.json /home/claude-dev/.claude.json
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
