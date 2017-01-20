# set fish_key_bindings fish_user_key_bindings

set -gx EDITOR vi

alias gs "git status"
alias gl "git l"
alias gco "git checkout"
alias nl "python3 ~/dev/neolaneIDE/neolaneIDE/__main__.py"

alias tn "tmux new-session -s "

function glf
  set -l branch (git rev-parse --abbrev-ref HEAD)
  gl $branch..origin/$branch $argv
end

function duf
  du --max-depth=1 $argv ^/dev/null
end

function nllog
  tail -f /var/log/syslog-ng/nlserver/(date +"%Y-%m-%d").log
end

function nlmon
  vi -c 'Nlmonitor'
end

# set -g JAVA_HOME (readlink -f /usr/bin/javac | sed "s:/bin/javac::")
# Setting ag as the default source for fzf
# set -g FZF_DEFAULT_COMMAND 'ag -g ""'
set -gx FZF_DEFAULT_COMMAND 'ag --hidden --ignore .git -g ""'
# To apply the command to CTRL-T as well
set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"

