# Fish Shell Configuration

# Suppress the default greeting
set -g fish_greeting ""

# Environment
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less

# XDG base dirs
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_CACHE_HOME "$HOME/.cache"

# PATH additions
fish_add_path "$HOME/.local/bin"
fish_add_path "$HOME/bin"

# Modern CLI tool aliases (if installed)
if command -q eza
    alias ls='eza --icons'
    alias ll='eza -la --icons --git'
    alias lt='eza --tree --icons'
end

if command -q bat
    alias cat='bat'
end

if command -q fd
    alias find='fd'
end

if command -q rg
    alias grep='rg'
end

if command -q btop
    alias top='btop'
end

if command -q zoxide
    zoxide init fish | source
end

# General aliases
alias ..='cd ..'
alias ...='cd ../..'
alias mkdir='mkdir -p'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Git aliases
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph'
alias gd='git diff'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Prompt: use starship if available, otherwise keep fish default
if command -q starship
    starship init fish | source
end
