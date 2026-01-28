FROM mcr.microsoft.com/devcontainers/python:3.13-bookworm

# Métadonnées
LABEL maintainer="votre-email@entreprise.com"
LABEL description="Dev container pour Claude Code avec proxy LLM entreprise"

# Variables d'environnement
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Supprimer le repo Yarn (clé GPG expirée - bug connu Microsoft) puis installer dépendances
RUN rm -f /etc/apt/sources.list.d/yarn.list \
    && apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Installer uv (gestionnaire de paquets Python rapide)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Installer Node.js LTS pour Claude Code CLI
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Installer Claude Code CLI globalement
RUN npm install -g @anthropic-ai/claude-code

# Créer le répertoire de travail
WORKDIR /workspace

# Cloner le projet claude-code-proxy
RUN git clone https://github.com/1rgs/claude-code-proxy.git /workspace/claude-code-proxy

# Installer les dépendances Python du proxy
WORKDIR /workspace/claude-code-proxy
RUN /root/.local/bin/uv sync

# Revenir au workspace principal
WORKDIR /workspace

# Exposer le port du proxy
EXPOSE 8082

# Script de démarrage par défaut
CMD ["bash"]
