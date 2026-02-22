export COLORTERM=truecolor
export TERM=${TERM:-xterm-256color}

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
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_REDUCE_BLANKS

export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

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

bindkey '^[[1;3C' end-of-line       # Alt + Right (line end)
bindkey '^[[1;3D' beginning-of-line # Alt + Left (line start)

bindkey '^[[1;9D' backward-word     # Super + Left (word backward)
bindkey '^[[1;9C' forward-word      # Super + Right (word forward)

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
