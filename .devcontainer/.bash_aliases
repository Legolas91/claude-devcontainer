# ==============================================================================
# Bash Aliases for Claude DevContainer
# ==============================================================================

# Common aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gpl='git pull'

# Docker aliases
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlogs='docker logs -f'

# Python aliases
alias py='python'
alias pip='python -m pip'
alias venv='python -m venv'

# Claude Code aliases
alias claude-proxy='cd /workspace/claude-code-proxy && uv run uvicorn server:app --host 0.0.0.0 --port 8082'
alias c='claude --dangerously-skip-permissions'

# Utility aliases
alias h='history'
alias c='clear'
alias reload='source ~/.bashrc'
