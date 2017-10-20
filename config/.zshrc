# setopt XTRACE VERBOSE
###############################################################################
# env
###############################################################################
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"
# Path to your oh-my-zsh installation.
export ZSH=$HOME/.config/oh-my-zsh

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
ZSH_THEME="geometry/geometry"
ZSH_THEME="spaceship"

plugins=(
  # git \
  man \
  taskwarrior \
  python \
  vi-mode \
  fasd \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  history-substring-search \
  )
source $ZSH/oh-my-zsh.sh

# vi-mode: disable default <<< NORMAL mode indicator in right prompt
export RPS1="%{$reset_color%}"


# fpath=($ZSH/custom/plugins/neolane-ide $fpath)
# fpath=(/home/arene/dev/neolaneIDE/data/scripts $fpath)

###############################################################################
# env
###############################################################################
# export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")
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
[ -n "$NVIM_LISTEN_ADDRESS" ] && export FZF_DEFAULT_OPTS='--no-height'

export KEYTIMEOUT=1

###############################################################################
# Aliases
###############################################################################
alias vi=nvim

# Tmux alias
tm() {
  local session
  newsession=${1:-main}
  session=$(tmux list-sessions -F "#{session_name}" | \
    fzf --query="$1" --select-1 --exit-0) &&
    tmux attach-session -t "$session" || tmux new-session -s $newsession
}

[ -n "$NVIM_LISTEN_ADDRESS" ] && alias nv='nvr -o'
# Git alias
alias gs='git status'
alias gc='git checkout'
# alias gl='git l'
gl() {
  branch=$(git rev-parse --abbrev-ref HEAD)
  origin_branch='master'
  case $branch in
    (acs-*|nl700-*)
      origin_branch='master'
      ;;
    (v7-*|v6-*|ac-*|nl600-*)
      origin_branch='v6-master'
      ;;
  esac
  git l origin/$origin_branch..
}

glf() {
  branch=$(git rev-parse --abbrev-ref HEAD)
  gl $branch..origin/$branch $argv
}

duf() {
  du --max-depth=1 $* 2> /dev/null
}
# fbr - checkout git branch (including remote branches)
fgc() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

fcs() {
  local commits commit
  commits=$(git log --color=always --pretty=oneline --abbrev-commit --reverse) &&
  commit=$(echo "$commits" | fzf --tac +s +m -e --ansi --reverse) &&
  echo -n $(echo "$commit" | sed "s/ .*//")
}

# fstash - easier way to deal with stashes
# type fstash to get a list of your stashes
# enter shows you the contents of the stash
# ctrl-d shows a diff of the stash against your current HEAD
# ctrl-b checks the stash out as a branch, for easier merging
fstash() {
  local out q k sha
  while out=$(
    git stash list --pretty="%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs" |
    fzf --ansi --no-sort --query="$q" --print-query \
        --expect=ctrl-d,ctrl-b);
  do
    mapfile -t out <<< "$out"
    q="${out[0]}"
    k="${out[1]}"
    sha="${out[-1]}"
    sha="${sha%% *}"
    [[ -z "$sha" ]] && continue
    if [[ "$k" == 'ctrl-d' ]]; then
      git diff $sha
    elif [[ "$k" == 'ctrl-b' ]]; then
      git stash branch "stash-$sha" $sha
      break;
    else
      git stash show -p $sha
    fi
  done
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
pw() {
  if [[ $(lpass status) = 'Not logged in.' ]]; then
    lpass login $LPASS_USERNAME || exit 1
  fi
  param='--password'
  if [[ $1 != '' ]]; then
    param=$1
  fi
  lpass show -c --color=never $param $(lpass ls | fzf | awk '{print $(NF)}' | sed 's/\]//g')
}

pwshow() {
  if [[ $(lpass status) = 'Not logged in.' ]]; then
    lpass login $LPASS_USERNAME || exit 1
  fi
  lpass show $1 $(lpass ls | fzf | awk '{print $(NF)}' | sed 's/\]//g')
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
# bindkey '^r' history-incremental-search-backward
bindkey '^f' vi-cmd-mode
bindkey '^l' forward-char

###############################################################################
# external
###############################################################################

[ -f ~/.zshrc_local ] && source ~/.zshrc_local
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(fasd --init posix-alias zsh-hook)"
[ -f ~/dev/neolaneIDE/data/scripts/bashenv.sh ] && source ~/dev/neolaneIDE/data/scripts/bashenv.sh
[ -f ~/.cargo/env ] && source ~/.cargo/env

###############################################################################
# ZSH_HIGHLIGHT
###############################################################################
# Declare the variable
typeset -A ZSH_HIGHLIGHT_STYLES

# To differentiate aliases from other command types
ZSH_HIGHLIGHT_STYLES[default]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[command]='fg=yellow,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=yellow,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=yellow,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=yellow,bold'
# ZSH_HIGHLIGHT_STYLES[path]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[path]='fg=magenta'

zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
# zstyle ':completion:*' verbose yes
#

###############################################################################
# Spaceship
###############################################################################
SPACESHIP_PROMPT_TRUNC=0
SPACESHIP_PROMPT_SYMBOL='»'

SPACESHIP_VI_MODE_INSERT=" "
SPACESHIP_VI_MODE_NORMAL="N"
SPACESHIP_VI_MODE_COLOR=cyan

SPACESHIP_DOCKER_SHOW=false

# GIT
# Disable git symbol
SPACESHIP_GIT_SYMBOL="" # disable git prefix
SPACESHIP_GIT_BRANCH_PREFIX="" # disable branch prefix too
# Wrap git in `git:(...)`
SPACESHIP_GIT_PREFIX='git:('
SPACESHIP_GIT_SUFFIX=") "
SPACESHIP_GIT_BRANCH_SUFFIX="" # remove space after branch name
# Unwrap git status from `[...]`
SPACESHIP_GIT_STATUS_PREFIX=""
SPACESHIP_GIT_STATUS_SUFFIX=""

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
