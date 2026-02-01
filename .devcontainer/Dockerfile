# ==============================================================================
# Claude DevContainer - Dockerfile
# Dev container pour Claude Code avec proxy LLM entreprise
# ==============================================================================

FROM mcr.microsoft.com/devcontainers/base:bookworm

# ------------------------------------------------------------------------------
# Build arguments
# ------------------------------------------------------------------------------
ARG TZ=Europe/Paris
ARG GIT_DELTA_VERSION=0.18.2
ARG CLAUDE_CODE_VERSION=latest

# ------------------------------------------------------------------------------
# Metadata
# ------------------------------------------------------------------------------
LABEL maintainer="philippe.dalessio@thalesgroup.com"
LABEL description="Dev container pour Claude Code avec proxy LLM entreprise"
LABEL version="3.0.0"

# ------------------------------------------------------------------------------
# Install system dependencies + networking tools + shell enhancements
# ------------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    jq \
    procps \
    ca-certificates \
    sudo \
    vim \
    nano \
    zsh \
    iptables \
    ipset \
    dnsutils \
    gh \
    locales \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# Timezone configuration
# ------------------------------------------------------------------------------
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# ------------------------------------------------------------------------------
# Locale configuration
# ------------------------------------------------------------------------------
RUN sed -i -e 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG=fr_FR.UTF-8 \
    LANGUAGE=fr_FR:en \
    LC_ALL=fr_FR.UTF-8

# ------------------------------------------------------------------------------
# Install Node.js LTS for Claude Code CLI
# ------------------------------------------------------------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# Install git-delta for enhanced diffs
# ------------------------------------------------------------------------------
RUN wget https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_amd64.deb \
    && dpkg -i git-delta_${GIT_DELTA_VERSION}_amd64.deb \
    && rm git-delta_${GIT_DELTA_VERSION}_amd64.deb

# ------------------------------------------------------------------------------
# Install fzf (fuzzy finder)
# ------------------------------------------------------------------------------
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /opt/fzf \
    && /opt/fzf/install --all --no-update-rc

# ------------------------------------------------------------------------------
# Rename existing vscode user to claude-dev and configure
# ------------------------------------------------------------------------------
RUN usermod -l claude-dev vscode \
    && groupmod -n claude-dev vscode \
    && usermod -d /home/claude-dev -m claude-dev \
    && usermod -s /bin/zsh claude-dev \
    && mkdir -p /home/claude-dev/.claude /commandhistory \
    && chown -R claude-dev:claude-dev /home/claude-dev /commandhistory \
    && echo "claude-dev ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/claude-dev \
    && chmod 0440 /etc/sudoers.d/claude-dev

# ------------------------------------------------------------------------------
# Configure npm for user dev
# ------------------------------------------------------------------------------
RUN mkdir -p /usr/local/share/npm-global \
    && chown -R claude-dev:claude-dev /usr/local/share/npm-global

USER claude-dev
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$NPM_CONFIG_PREFIX/bin:$PATH

# ------------------------------------------------------------------------------
# Install Claude Code CLI as dev user
# ------------------------------------------------------------------------------
RUN npm install -g @anthropic-ai/claude-code \
    && npm cache clean --force

# ------------------------------------------------------------------------------
# Install and configure zsh plugins
# ------------------------------------------------------------------------------
RUN git clone https://github.com/zsh-users/zsh-autosuggestions /home/claude-dev/.zsh/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting /home/claude-dev/.zsh/zsh-syntax-highlighting \
    && chown -R claude-dev:claude-dev /home/claude-dev/.zsh \
    && echo 'source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh' >> /home/claude-dev/.zshrc \
    && echo 'source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> /home/claude-dev/.zshrc \
    && echo 'PROMPT="%F{green}%n@%m%f:%F{blue}%~%f$ "' >> /home/claude-dev/.zshrc

# ------------------------------------------------------------------------------
# Configure bash history persistence
# ------------------------------------------------------------------------------
RUN echo 'export HISTFILE=/commandhistory/.bash_history' >> /home/claude-dev/.bashrc \
    && echo 'export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"' >> /home/claude-dev/.bashrc

# ------------------------------------------------------------------------------
# Configure git-delta
# ------------------------------------------------------------------------------
RUN git config --global core.pager "delta" \
    && git config --global interactive.diffFilter "delta --color-only" \
    && git config --global delta.navigate true \
    && git config --global delta.light false \
    && git config --global merge.conflictstyle diff3 \
    && git config --global diff.colorMoved default

# ------------------------------------------------------------------------------
# Configure default editor
# ------------------------------------------------------------------------------
ENV EDITOR=nano
ENV VISUAL=nano

# ------------------------------------------------------------------------------
# Configure Claude CLI environment
# ------------------------------------------------------------------------------
ENV CLAUDE_CONFIG_DIR=/home/claude-dev/.claude
ENV NODE_OPTIONS="--max-old-space-size=4096"

# ------------------------------------------------------------------------------
# Switch back to root for remaining setup
# ------------------------------------------------------------------------------
USER root

# ------------------------------------------------------------------------------
# Setup directories
# ------------------------------------------------------------------------------
WORKDIR /workspace
RUN mkdir -p /usr/local/bin/proxy-scripts \
    && chown -R claude-dev:claude-dev /workspace

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
# Copy and configure firewall initialization script
# ------------------------------------------------------------------------------
COPY scripts/init-firewall.sh /usr/local/bin/init-firewall.sh
RUN chmod +x /usr/local/bin/init-firewall.sh

# ------------------------------------------------------------------------------
# Environment variables
# ------------------------------------------------------------------------------
ENV ANTHROPIC_BASE_URL=http://localhost:8082

# ------------------------------------------------------------------------------
# Expose proxy port
# ------------------------------------------------------------------------------
EXPOSE 8082

# ------------------------------------------------------------------------------
# Switch to dev user for runtime
# ------------------------------------------------------------------------------
USER claude-dev

# ------------------------------------------------------------------------------
# Default command
# ------------------------------------------------------------------------------
CMD ["zsh"]
