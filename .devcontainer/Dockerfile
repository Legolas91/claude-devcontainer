# ==============================================================================
# Claude DevContainer - Dockerfile
# Dev container pour Claude Code avec proxy LLM entreprise
# ==============================================================================

FROM mcr.microsoft.com/devcontainers/python:3.13-bookworm

# ------------------------------------------------------------------------------
# Version pinning
# ------------------------------------------------------------------------------
ARG UV_VERSION=0.5.18
ARG NODE_MAJOR=22
ARG CLAUDE_CODE_VERSION=latest

# ------------------------------------------------------------------------------
# Metadata
# ------------------------------------------------------------------------------
LABEL maintainer="philippe.dalessio@thalesgroup.com"
LABEL description="Dev container pour Claude Code avec proxy LLM entreprise"
LABEL version="1.0.0"

# ------------------------------------------------------------------------------
# Shell configuration for safer scripts
# ------------------------------------------------------------------------------
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# ------------------------------------------------------------------------------
# Environment variables
# ------------------------------------------------------------------------------
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

# ------------------------------------------------------------------------------
# Install system dependencies
# ------------------------------------------------------------------------------
# Remove problematic Yarn repository (known Microsoft bug)
# Install essential tools: git, curl, ca-certificates
RUN rm -f /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        curl \
        ca-certificates \
        gnupg \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ------------------------------------------------------------------------------
# Install uv (Python package manager)
# https://github.com/astral-sh/uv
# ------------------------------------------------------------------------------
RUN curl -LsSf "https://astral.sh/uv/${UV_VERSION}/install.sh" -o /tmp/uv-install.sh \
    && chmod +x /tmp/uv-install.sh \
    && /tmp/uv-install.sh \
    && rm -f /tmp/uv-install.sh

ENV PATH="/root/.local/bin:$PATH"

# ------------------------------------------------------------------------------
# Install Node.js LTS
# https://github.com/nodesource/distributions
# ------------------------------------------------------------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x -o /tmp/nodesource_setup.sh \
    && chmod +x /tmp/nodesource_setup.sh \
    && bash /tmp/nodesource_setup.sh \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ------------------------------------------------------------------------------
# Install Claude Code CLI
# https://www.npmjs.com/package/@anthropic-ai/claude-code
# ------------------------------------------------------------------------------
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} \
    && npm cache clean --force

# ------------------------------------------------------------------------------
# Setup workspace
# ------------------------------------------------------------------------------
WORKDIR /workspace

# ------------------------------------------------------------------------------
# Clone claude-code-proxy repository
# https://github.com/1rgs/claude-code-proxy
# ------------------------------------------------------------------------------
RUN git clone --depth 1 https://github.com/1rgs/claude-code-proxy.git /workspace/claude-code-proxy

# ------------------------------------------------------------------------------
# Install proxy dependencies
# ------------------------------------------------------------------------------
WORKDIR /workspace/claude-code-proxy
RUN /root/.local/bin/uv sync \
    && rm -rf /tmp/* /var/tmp/*

# ------------------------------------------------------------------------------
# Return to main workspace
# ------------------------------------------------------------------------------
WORKDIR /workspace

# ------------------------------------------------------------------------------
# Expose proxy port
# ------------------------------------------------------------------------------
EXPOSE 8082

# ------------------------------------------------------------------------------
# Health check (for proxy service)
# ------------------------------------------------------------------------------
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8082/ || exit 1

# ------------------------------------------------------------------------------
# Default command
# ------------------------------------------------------------------------------
CMD ["bash"]
