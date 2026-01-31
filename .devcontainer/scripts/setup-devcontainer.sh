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
