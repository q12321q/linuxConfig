# setopt XTRACE VERBOSE
# zmodload zsh/zprof

###############################################################################
# env PATH
###############################################################################
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
export NVM_DIR="$HOME/.nvm"
export MNT_DIR="$HOME/mnt"

#export GITHUB_TOKEN=$(security find-generic-password -a ${USER} -s github_token -w)
export ARTIFACTORY_USER=arene
export ARTIFACTORY_API_TOKEN=$(security find-generic-password -a ${USER} -s apikey@artifactory.corp.adobe.com -w)

###############################################################################
# Zgen
###############################################################################
# load zgen
source "${HOME}/.zgen/zgen.zsh"

if ! zgen saved; then
  zgen oh-my-zsh
  zgen oh-my-zsh plugins/vi-mode
  zgen oh-my-zsh plugins/fasd
  zgen oh-my-zsh plugins/docker
  zgen oh-my-zsh plugins/docker-compose

  zgen load lukechilds/zsh-nvm
  zgen load lukechilds/zsh-better-npm-completion
  zgen load zsh-users/zsh-completions
  zgen load zsh-users/zsh-history-substring-search
  zgen load zsh-users/zsh-syntax-highlighting
  zgen load zsh-users/zsh-autosuggestions

  zgen load denysdovhan/spaceship-zsh-theme spaceship

  zgen save
fi

###############################################################################
# external
###############################################################################

[ -f ~/.zshrc_local ] && source ~/.zshrc_local

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(fasd --init posix-alias zsh-hook)"
[ -f ~/dev/neolaneIDE/data/scripts/bashenv.sh ] && source ~/dev/neolaneIDE/data/scripts/bashenv.sh
[ -f ~/.cargo/env ] && source ~/.cargo/env
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

###############################################################################
# env
###############################################################################
export EDITOR=$(which nvim)
export MANPAGER="nvim -c 'set ft=man' -"
# Add colors to ls
export CLICOLOR=''

# FZF
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'
export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'  --preview-window right:80:hidden:wrap --bind '?:toggle-preview'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
# To apply the command to CTRL-T as well
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
[ -n "$NVIM_LISTEN_ADDRESS" ] && export FZF_DEFAULT_OPTS='--no-height'

export KEYTIMEOUT=1

###############################################################################
# keys
###############################################################################
autoload -U edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line
bindkey '^f' edit-command-line
bindkey '^f' edit-command-line
bindkey '^x^e' edit-command-line

###############################################################################
# Aliases
###############################################################################
alias la="ls -A"
alias ll="ls -l"
alias c1="awk '{print \$1}'"
alias c2="awk '{print \$2}'"
alias c3="awk '{print \$3}'"
alias c4="awk '{print \$4}'"
alias c5="awk '{print \$5}'"
alias c6="awk '{print \$6}'"
alias c7="awk '{print \$7}'"
alias c8="awk '{print \$8}'"
alias c9="awk '{print \$9}'"

# smenu
alias sm=smenu
cm() {
  smenu -l -n 50 $* | pbcopy
}

# Vim aliases
alias vi=nvim
[ -n "$NVIM_LISTEN_ADDRESS" ] && alias nv='nvr -o'

# mount aliases
smb() {
  local smb_path
  local jmb_name
  if [[ -z "$*" ]]; then
    echo "usage: smb //<user>@<host>/<path> name"
    return 1
  elif [[ -z "$MNT_DIR" ]]; then
    echo "MNT_DIR must be set!"
    return 1
  else
    smb_path="$1"
    smb_name="$2"

    mkdir -p "$MNT_DIR/$smb_path"
    mount -t smbfs "$smb_path" "$MNT_DIR/$smb_name"
  fi
}

# Tmux aliases
tm() {
  local session
  newsession=${1:-main}
  session=$(tmux list-sessions -F "#{session_name}" | \
    fzf --query="$1" --select-1 --exit-0) &&
    tmux attach-session -t "$session" || tmux new-session -s $newsession
}

if [ "$(uname)" == "Darwin" ]; then
  alias find='gfind'
  alias grep='ggrep'
  alias sed='gsed'
fi

# Git aliases
alias dc='docker-compose'
# Git aliases
alias gs='git status'
alias gc='git checkout'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git l -20'
alias remove-color='gsed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"'
# fbr - checkout git branch (including remote branches), sorted by most recent commit, limit 30 last branches
gb() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           # fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
           fzf) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}
gco() {
  local tags branches target
  tags=$(
    git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}') || return
  branches=$(
    git branch --all | grep -v HEAD             |
    sed "s/.* //"    | sed "s#remotes/[^/]*/##" |
    sort -u          | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}') || return
  target=$(
    (echo "$tags"; echo "$branches") | fzf --ansi) || return
  git checkout $(echo "$target" | awk '{print $2}')
}
# fstash - easier way to deal with stashes
# type fstash to get a list of your stashes
# enter shows you the contents of the stash
# ctrl-d shows a diff of the stash against your current HEAD
# ctrl-b checks the stash out as a branch, for easier merging
gstash() {
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
gsha() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
      fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort |
      remove-color |
      sed 's/\([a-z0-9]\{9\}\).*/\1/' |
      sed 's/.*\([a-z0-9]\{9\}\)/\1/' |
      tr -d '\n'
}

gls() {
  git -c color.status=always status -s $@ |fzf --ansi --multi| awk '{print $2}'
}
gadd() {
  git add `gls`
}
gll() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --prompt="git show> "
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}
glb() {
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

ga() {
  files=$(git ls-files -m | fzf --multi --prompt='git add --all>') &&
  git add --all ${files}
}

gau() {
  files=$(git status -s | awk '$1 == "??" {print $2}' | fzf --multi --prompt='git add --all>') &&
  git add --all ${files}
}
gac() {
  files=$(git status -s | awk '$1 == "UU" {print $2}' | fzf --multi --prompt='git add --all>') &&
  git add --all ${files}
}
ga() {
  files=$(git status -s | awk '$0 ~ /^M / {print $2}' | fzf --multi --prompt='git add --all>') &&
  git add --all ${files}
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

# Fasd aliases
unalias zz
zz() {
  if [[ $1 = '-' ]]; then
    cd "$(fasd_cd -d -l -t -R 2>&1 | sed -n 's/^[ 0-9.,]*//p' | fzf --no-sort)"
  elif [[ -z "$*" ]]; then
    cd "$(fasd_cd -d -l -R 2>&1 | sed -n 's/^[ 0-9.,]*//p' | fzf --no-sort)"
  else
    fasd_cd -d "$@"
  fi
}
#
# Print the name of the git repository's working tree's root directory
# Search for 'Tom Hale' in http://stackoverflow.com/questions/957928/is-there-a-way-to-get-the-git-root-directory-in-one-command
# Or, shorter: 
# (root=$(git rev-parse --git-dir)/ && cd ${root%%/.git/*} && git rev-parse && pwd)
# but this doesn't cover external $GIT_DIRs which are named other than .git
function git_root {
  local root first_commit
  # git displays its own error if not in a repository
  root=$(git rev-parse --show-toplevel) || return
  if [[ -n $root ]]; then
    echo "$root"
    return
  elif [[ $(git rev-parse --is-inside-git-dir) = true ]]; then
    # We're inside the .git directory
    # Store the commit id of the first commit to compare later
    # It's possible that $GIT_DIR points somewhere not inside the repo
    first_commit=$(git rev-list --parents HEAD | tail -1) ||
      echo "$0: Can't get initial commit" 2>&1 && false && return
    root=$(git rev-parse --git-dir)/.. &&
      # subshell so we don't change the user's working directory
    ( cd "$root" &&
      if [[ $(git rev-list --parents HEAD | tail -1) = "$first_commit" ]]; then
        pwd
      else
        echo "${FUNCNAME[0]}: git directory is not inside its repository" 2>&1
        false
      fi
    )
  else
    echo "${FUNCNAME[0]}: Can't determine repository root" 2>&1
    false
  fi
}

# Change working directory to git repository root
function cdr {
  local root
  root=$(git_root) || return $? # git_root will print any errors
  cd "$root" || return $?
}

function httpbin {
  docker run --rm -p 127.0.0.1:${1:-80}:80 \
             --name "httpbin" \
             kennethreitz/httpbin
}

alias urldecode='python -c "import sys, urllib as ul; \
    print ul.unquote_plus(sys.argv[1])"'

alias urlencode='python -c "import sys, urllib as ul; \
    print ul.quote_plus(sys.argv[1])"'

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

# vi-mode: disable default <<< NORMAL mode indicator in right prompt
export RPS1="%{$reset_color%}"
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
#
zstyle ':bracketed-paste-magic' active-widgets '.self-*'

###############################################################################
# Spaceship
###############################################################################
SPACESHIP_PROMPT_TRUNC=0
SPACESHIP_CHAR_SYMBOL='» '

SPACESHIP_VI_MODE_INSERT=" "
SPACESHIP_VI_MODE_NORMAL="N"
SPACESHIP_VI_MODE_COLOR=cyan

SPACESHIP_DOCKER_SHOW=false
SPACESHIP_BATTERY_SHOW=false

# Directory (dir)
SPACESHIP_DIR_TRUNC=0
SPACESHIP_DIR_TRUNC_REPO=false

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

# Exit code
SPACESHIP_EXIT_CODE_SYMBOL=""
SPACESHIP_EXIT_CODE_SHOW=true
# zprof
#
## Module name: taskwarrior
# Module description: displays Taskwarrior tasklist
check_task=$( which task 2>/dev/null )
if [ -n "${check_task}" ]; then
  task
fi
[[ ! $TERM =~ screen ]] && [ -z $TMUX ] && { tmux attach || exec tmux new-session;}
