# setopt XTRACE VERBOSE
###############################################################################
# env
###############################################################################
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"
# Path to your oh-my-zsh installation.
export ZSH=/home/arene/.config/oh-my-zsh

###############################################################################
# ZSH
###############################################################################

ZSH_THEME="steeef"
# ZSH_THEME="kennethreitz"
# ZSH_THEME="af-magic"
ZSH_THEME="kafeitu"
ZSH_THEME="random"
ZSH_THEME="avit"
ZSH_THEME="ys"
ZSH_THEME="q12321q"

plugins=(
  git \
  man \
  taskwarrior \
  python \
  vi-mode \
  fasd \
  history-substring-search \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  )

source $ZSH/oh-my-zsh.sh

# fpath=($ZSH/custom/plugins/neolane-ide $fpath)
# fpath=(/home/arene/dev/neolaneIDE/data/scripts $fpath)

###############################################################################
# env
###############################################################################
export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")
# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi
export EDITOR=/usr/bin/vim
export MANPAGER="nvim -c 'set ft=man' -"

# FZF
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'
# To apply the command to CTRL-T as well
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export KEYTIMEOUT=1

###############################################################################
# Aliases
###############################################################################
# Tmux alias
tls() {
  local session
  session=$(tmux list-sessions -F "#{session_name}" | \
    fzf --query="$1" --select-1 --exit-0) &&
  tmux switch-client -t "$session"
}

tn() {
  tmux new-session -s "$1"
}

# Git alias
alias gs='git status'
# alias gl='git l'
# gl() {
#   git l origin/master..
# }

duf() {
  du --max-depth=1 $* 2> /dev/null
}


# Neolane
alias nlmon='vi -c Nlmonitor'
nl() {
  python3 ~/dev/neolaneIDE/neolaneIDE/__main__.py $*
}
nltags() {
  find -name \*.cpp -or -name \*.h | ctags -L -
}
nllog() {
  tail -f /var/log/syslog-ng/nlserver/`date +"%Y-%m-%d"`.log
}

###############################################################################
# bindkey
###############################################################################
bindkey -v

# bindkey '^P' up-history
# bindkey '^N' down-history
bindkey '^p' history-substring-search-up
bindkey '^n' history-substring-search-down
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward
bindkey '^f' vi-cmd-mode
bindkey '^l' forward-char

###############################################################################
# external
###############################################################################

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(fasd --init posix-alias zsh-hook)"
source ~/dev/neolaneIDE/data/scripts/bashenv.sh

###############################################################################
# ZSH_HIGHLIGHT
###############################################################################
# Declare the variable
typeset -A ZSH_HIGHLIGHT_STYLES

# To differentiate aliases from other command types
ZSH_HIGHLIGHT_STYLES[command]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=magenta,bold'
