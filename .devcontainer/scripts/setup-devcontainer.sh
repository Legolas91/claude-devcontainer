#!/bin/bash
# ==============================================================================
# Setup script for Claude DevContainer
# ==============================================================================

set -e  # Exit on error

echo "🚀 Starting Claude DevContainer setup..."

# ==============================================================================
# Install bash configuration
# ==============================================================================
echo "📝 Installing bash configuration..."

if [ -f /workspace/claude-devcontainer/.devcontainer/.bash_aliases ]; then
    cp /workspace/claude-devcontainer/.devcontainer/.bash_aliases ~/.bash_aliases

    # Add source to .bashrc if not already present (idempotent)
    if ! grep -q "source ~/.bash_aliases" ~/.bashrc; then
        echo "" >> ~/.bashrc
        echo "# Source custom aliases" >> ~/.bashrc
        echo "if [ -f ~/.bash_aliases ]; then" >> ~/.bashrc
        echo "    source ~/.bash_aliases" >> ~/.bashrc
        echo "fi" >> ~/.bashrc
    fi
    echo "✅ Bash aliases installed"
else
    echo "⚠️  .bash_aliases not found, skipping..."
fi

# ==============================================================================
# Fix permissions
# ==============================================================================
echo "🔒 Fixing permissions..."

# Fix permissions for workspace
if [ -d /workspace/claude-devcontainer ]; then
    sudo chown -R vscode:vscode /workspace/claude-devcontainer 2>/dev/null || true
fi

# ==============================================================================
# Install Python dependencies
# ==============================================================================
echo "🐍 Installing Python dependencies..."

# Upgrade pip
python -m pip install --upgrade pip --quiet

# Install common Python tools
python -m pip install --quiet \
    black \
    pylint \
    pytest \
    pytest-cov

echo "✅ Python tools installed"

# ==============================================================================
# Display info
# ==============================================================================
echo ""
echo "✅ Claude DevContainer setup complete!"
echo ""
echo "📦 Installed tools:"
echo "  - Python $(python --version 2>&1 | cut -d' ' -f2)"
echo "  - Node.js $(node --version)"
echo "  - npm $(npm --version)"
echo "  - Docker $(docker --version | cut -d' ' -f3 | tr -d ',')"
echo ""
echo "🔗 Proxy: http://proxy:8082"
echo "📚 Documentation: /workspace/claude-devcontainer/README.md"
echo ""
