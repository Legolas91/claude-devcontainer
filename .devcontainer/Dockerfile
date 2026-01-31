# ==============================================================================
# Claude DevContainer - Dockerfile
# Dev container pour Claude Code avec proxy LLM entreprise
# ==============================================================================

FROM mcr.microsoft.com/devcontainers/base:bookworm

# ------------------------------------------------------------------------------
# Metadata
# ------------------------------------------------------------------------------
LABEL maintainer="philippe.dalessio@thalesgroup.com"
LABEL description="Dev container pour Claude Code avec proxy LLM entreprise"
LABEL version="2.0.0"

# ------------------------------------------------------------------------------
# Install system dependencies
# ------------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    jq \
    procps \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# Install Node.js LTS for Claude Code CLI
# ------------------------------------------------------------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# Install Claude Code CLI
# ------------------------------------------------------------------------------
RUN npm install -g @anthropic-ai/claude-code \
    && npm cache clean --force

# ------------------------------------------------------------------------------
# Setup directories
# ------------------------------------------------------------------------------
WORKDIR /workspace
RUN mkdir -p /root/.claude /usr/local/bin/proxy-scripts

# ------------------------------------------------------------------------------
# Copy and install proxy binary (pre-compiled for Linux)
# ------------------------------------------------------------------------------
COPY bin/claude-code-proxy /usr/local/bin/claude-code-proxy
RUN chmod +x /usr/local/bin/claude-code-proxy

# ------------------------------------------------------------------------------
# Copy proxy scripts
# ------------------------------------------------------------------------------
COPY scripts/*.sh /usr/local/bin/proxy-scripts/
RUN chmod +x /usr/local/bin/proxy-scripts/*.sh

# Create aliases for scripts
RUN ln -sf /usr/local/bin/proxy-scripts/start-proxy.sh /usr/local/bin/start-proxy \
    && ln -sf /usr/local/bin/proxy-scripts/stop-proxy.sh /usr/local/bin/stop-proxy \
    && ln -sf /usr/local/bin/proxy-scripts/test-proxy.sh /usr/local/bin/test-proxy

# ------------------------------------------------------------------------------
# Environment variables
# ------------------------------------------------------------------------------
ENV ANTHROPIC_BASE_URL=http://localhost:8082

# ------------------------------------------------------------------------------
# Expose proxy port
# ------------------------------------------------------------------------------
EXPOSE 8082

# ------------------------------------------------------------------------------
# Default command
# ------------------------------------------------------------------------------
CMD ["bash"]
