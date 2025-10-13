# zshaliases.plugin.zsh: Define aliases for an interactive shell
#
# vim : set et ft=zsh sts=2 sw=2 tw=0 :

# If this is not an interactive shell, abort.
case $- in
  (*i*) ;;
    (*) return ;;
esac

function coproc_printx() {
  emulate -LR zsh
  unsetopt monitor
  trap '' HUP INT QUIT
  if command -v bat > /dev/null; then
    coproc bat --paging=never --style=plain --decorations=always --color=always --theme=TwoDark --language=zsh && disown %%
  else
    coproc cat && disown %%
  fi
}
function preexec_printx() {
  emulate -LR zsh
  typeset -g coproc_printx_pid
  local pfx='*↝'
  local cmd="$2"
  if [[ "$2" == "$1" ]]; then
    return 0
  fi
  if
    print -p -- "$2" || {
      coproc_printx < /dev/null > /dev/null 2>&1 && print -p -- "$2"
    }
  then
    read -p -r 2 && print -f '\e[0;1;2;3;90m%s\e[0;3m \e[0;1m%s\n' -- "${pfx}" "$2"
  fi 2> /dev/null
}
preexec_functions+=(preexec_printx)

# default command options
alias cp='cp -iv'
alias df='df -h'
alias dfx='df --exclude-type=tmpfs --exclude-type=devtmpfs --exclude-type=squashfs'
alias diff='diff --color=auto'
alias dir='dir --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias gdb='gdb -q'
alias grep='grep --color=auto'
alias ip='ip -c'
alias ls='ls -CFhv --color=auto'
alias mkdir='mkdir -pv'
alias mv='mv -iv'
alias rm='rm -Iv'
alias rmdir='rmdir -v'
alias vdir='vdir --color=auto'
alias df='df --exclude-type=tmpfs'


# clear
alias c='clear'


# dirs
alias po='popd'
alias pu='pushd'
alias -- -='popd'
alias -- +='pushd'


# jobs
alias j='jobs -lp'


# ls
alias l='ls'
alias la='ls -A'
alias lr='ls -1R'
alias lt='ls -1t'
alias lar='ls -1AR'
alias lat='ls -1At'
alias lart='ls -1ARt'
alias ll='ls -l'
alias lla='ls -Al'
alias llr='ls -lR'
alias llt='ls -lt'
alias llar='ls -lAR'
alias llat='ls -lAt'
alias llart='ls -lARt'


# man
alias m='man'


# ps
typeset -g -x PS_FORMAT="user=UID,pid,ppid,c,stime,tname,time,cmd"
typeset -g -x PS_PERSONALITY="linux"

alias p='ps'
alias px='p x'
alias pa='ps ax'

# pstree
if command -v pstree > /dev/null; then
  alias pstree='pstree -p'
else
  alias pstree='ps x --forest'
fi
alias pt='pstree'


# lsblk w/ default opts - show filesystems and permissions in a tree
alias lsblk='lsblk --fs --tree'


# python
if command -v python3 > /dev/null
then
  alias python='python3'
elif command -v python2 > /dev/null
then
  alias python='python2'
fi
alias py='python'
alias py2='python2'
alias py3='python3'


# vim / neovim
alias v='vim'
if command -v nvim > /dev/null; then
  alias vim='nvim'
  alias nvimdiff='nvim -d'
  alias vimdiff='nvimdiff'
fi


# top
if command -v btm > /dev/null; then
  alias top='btm'
elif command -v htop > /dev/null; then
  alias top='htop'
elif command -v gtop > /dev/null; then
  alias top='gtop'
fi


# clipcopy
alias clipfmt="clippaste | clipcopy"


# tmux
if command -v tmux > /dev/null; then
  alias t='tmux'
  alias ta='tmux attach-session -f ignore-size'
  alias tn='tmux new-session'
  alias tw='tmux new-window'
  alias tl='tmux list-sessions' 
  function tmux-new-session-window() {
    if (($# != 1)); then
      >&2 printf 'usage: tmux-attach-new-session-window SESSION_NAME\n' 
      return 2
    fi
    tmux new-session -d -t "$1" ";" "new-window" ";" "attach-session"
  }
  function fz-tmux-new-session-window() {
    emulate -RL zsh
    fzf=("${(z)$(__fzfcmd):-fzf}")
    if tmux has-session; then
      session_group="$(
        tmux list-sessions -F "#S" | sort -u | FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS}" "${fzf[@]}" --cycle
      )"
      if [[ "$#" -eq 0 && -n "${session_group}" ]]; then
        tmux-new-session-window "${session_group}"
      fi
    fi
    return "$#"
  }
  if command -v fzf > /dev/null; then
    alias tnsw='fz-tmux-new-session-window'
  else
    alias tnsw='tmux-new-session-window'
  fi
fi


# feh
if command -v feh > /dev/null; then
  alias feh-slideshow='feh --auto-zoom --image-bg black --slideshow-delay 8'
fi


# query DNS servers for my WAN IP
alias wanip4='dig @resolver1.opendns.com -4 myip.opendns.com +short'
alias wanip6='dig @resolver1.opendns.com -6 myip.opendns.com +short'
alias wanip='wanip4'


# tree customization
if command -v tree > /dev/null; then
  function tree() {
    emulate -LR zsh
    local -T TREE="${TREE}" tree ' '
    local options=(-CFlv --dirsfirst --filelimit 10000 --gitignore)
    local ignore_from=("${XDG_CONFIG_HOME:-${HOME}/.config}"/git/ignore(-.N))
    local ignore_list=("${(f)$(< "${ignore_from[@]-/dev/null}")}") 2> /dev/null
    if test "${#ignore_list[@]}" -gt 0; then
      options+=(-I "(${(j:|:)ignore_list[@]%%(\/##\*#)#})")
    fi
    command tree "${tree[@]}" "${(@)options:|tree}" "$@"
  }
  typeset -xT TREE tree ' '
  tree=(-CFlv --dirsfirst --filelimit 10000 -L 10)
  alias tree="'tree'"
fi


# date-iso - print the date and time in ISO 8601 format up to the given precision (default: seconds)
# usage: date-iso [date|hours|minutes|seconds|ns]
function date-iso () {
  date --iso-8601 "${1-seconds}" "${@:2}"
}

# dutree - show a summary of disk usage for a directory tree - from root to leaves
# usage: dutree [du-options] directory
function dutree () {
  emulate -LR zsh
  local tree
  local -a -U du_options=(--dereference-args --human-readable --total)
  if test "$#" -lt 1
  then
    >&2 printf 'usage: dutree [du-options] directory\n' 
    return 2
  fi
  tree="${@[-1]}"
  du_options+=("${@:1:-1}")
  du "${du_options[@]}" "${tree}" | sort -h -b --key "1,1"
}
