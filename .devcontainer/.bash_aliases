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

# Claude Code aliases
alias cc='claude'
alias proxy-logs='cat /tmp/claude-code-proxy.log'
alias proxy-status='curl -s http://localhost:8082/ | jq'

# Utility aliases
alias h='history'
alias cls='clear'
alias reload='source ~/.bashrc'
