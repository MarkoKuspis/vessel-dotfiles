# Path to spaceship config
export SPACESHIP_CONFIG="$HOME/.config/spaceship.zsh"

# Source spaceship prompt
source /usr/lib/spaceship-prompt/spaceship.zsh

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# Completion
autoload -Uz compinit
compinit

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Colored completion (LS_COLORS)
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Enable menu select
zstyle ':completion:*' menu select

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -lah'
alias grep='grep --color=auto'

# Enable colors
autoload -U colors && colors
