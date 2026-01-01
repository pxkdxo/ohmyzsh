# zshaliases.plugin.zsh: aliases for an interactive shell


# If this is not an interactive shell, abort.
case $- in
  (*i*) ;;
    (*) return ;;
esac


# show alias expansion before command execution
function __preexec_printex() {
  emulate -LR zsh
  case "$1" in "$2"*) return ;; esac
  case "$2" in "$1"*) return ;; esac
  printf '\e[0;1;3;30m ↪\e[0m \e[2m%s\e[0m\n' "$2" >&2
} && autoload -Uz add-zsh-hook && add-zsh-hook preexec __preexec_printex


# history shortcuts
alias history-load='fc -RI'


# sudo aliases to expand command aliases that follow
alias sudo='sudo '
alias -- -A='-A ' --askpass='--askpass '
alias -- -b='-b ' --background='--background '
alias -- -H='-H ' --set-home='--set-home '
alias -- -i='-i ' --login='--login '
alias -- -l='-l ' --list='--list '
alias -- -n='-n ' --non-interactive='--non-interactive '
alias -- -P='-P ' --preservce-group='--preserve-groups '
alias -- -s='-s ' --shell='--shell '
alias -- -S='-S ' --stdin='--stdin '


# default options
alias cp='cp -iv'
alias df='df -h'
alias diff='diff --color=auto'
alias dir='dir --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias ip='ip -c'
alias ls='ls -CFhv --color=auto'
alias mkdir='mkdir -pv'
alias mv='mv -iv'
alias rm='rm -Iv'
alias rmdir='rmdir -v'
alias vdir='vdir --color=auto'
alias lsblk='lsblk --fs --tree'


# clear
alias c='clear'


# dirs
alias d='cd'
alias -- '-=cd'
alias dp='pushd`'
alias pd='popd'
alias dd='dirs'
function __alias_pushd_commands() {
  local sign=""
  local -i n=0
  local -i m="${DIRSTACKSIZE:-10}"
  if [[ -o pushdminus ]]; then
    alias -- "+=pushd ${sign:="-"}1"
  else
    alias -- "+=pushd ${sign:="+"}1"
  fi
  while (( n++ < m )); do
    alias -- "+$((n))=pushd ${sign}$((n))"
  done
} && __alias_pushd_commands


# jobs
alias jobs='jobs -l'


# man
alias m='man'


# ls
alias l='ls'
alias ll='ls -l'
alias la='ls -l -A'
alias lr='ls -l -R'
alias lt='ls -l -r -t'
alias lar='ls -l -A -R'
alias lat='ls -l -A -r -t'
alias lart='ls -l -A -r -t -R'


# lsd replacement
if command -v eza > /dev/null; then
  alias ls='eza'
elif command -v lsd > /dev/null; then
  alias ls='lsd'
fi


# less replacement
if command -v bat > /dev/null; then
  alias less='bat'
fi


# ps
typeset -g -x PS_FORMAT="user=UID,pid,ppid,c,stime,tname,time,cmd"
typeset -g -x PS_PERSONALITY="linux"

alias p='ps'
alias px='p x'
alias pa='p ax'


# pstree
if command -v pstree > /dev/null; then
  alias pstree='pstree -p'
else
  alias pstree='ps x --forest'
fi


# python
alias py='python'
alias py2='python2'
alias py3='python3'
alias ipy='ipython'
if command -v python3 > /dev/null
then
  alias python='python3'
fi


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


# ripgrep
alias rg='rg --heading --line-number --follow --hidden --no-ignore-global --no-ignore-parent'
alias rg+='rg --unrestricted'


# fd
alias fd='fd --follow --hidden --no-ignore-parent'
alias fd+='fd --unrestricted'


# clipcopy
if [[ "${(L)OSTYPE:-$(uname -s 2> /dev/null)}" == darwin* ]] && command -v pbcopy > /dev/null; then
  alias pbcopy='pbcopy'
  alias pbpaste='pbpaste'
elif [[ -n "${WAYLAND_DISPLAY:-}" ]] && command -v wl-copy > /dev/null; then
  alias pbcopy='wl-copy -n'
  alias pbpaste='wl-paste'
elif command -v xclip > /dev/null; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
elif command -v xsel > /dev/null; then
  alias pbcopy='xsel --clipboard --input'
  alias pbpaste='xsel --clipboard --output'
elif command -v clipcopy > /dev/null; then
  alias pbcopy='clipcopy'
  alias pbpaste='clippaste'
fi
alias pbfmt="pbpaste | pbcopy"


# tmux
if command -v tmux > /dev/null; then
  alias tm='tmux'
  alias tma='tmux attach-session -f ignore-size'
  alias tms='tmux new-session'
  alias tmw='tmux new-window'
  alias tml='tmux list-sessions' 
  function tmux-session-window() {
    if (($# != 1)); then
      >&2 printf 'usage: tmux-session-window SESSION_NAME\n' 
      return 2
    fi
    tmux new-session -d -t "$1" \; new-window \; attach-session
  }
  if command -v fzf > /dev/null; then
    function fzf-tmux-session-window() {
      emulate -LR zsh
      local session_group
      local fzf=(
        "${(z)$(__fzfcmd):-fzf}"
        --cycle
        --exit-0
        --select-1
        --height=65%
        --min-height=5+
        --info=right
        --info-command='tmux list-panes -F '$'* #S:#I.#P\t#W:#T'' -a'
        --preview-window='bottom,80%,border-sharp,nowrap,nocycle,noinfo'
        --preview='tmux capture-pane -p -e -J -t {}'
      )
      tmux has-session &&
        session_group="$(tmux list-sessions -F "#S" | sort -u | FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS}" "${fzf[@]}")" &&
        [[ -n "${session_group}" ]] &&
        tmux new-session -d -t "${session_group}" \; new-window \; attach-session
    }
    alias tmsw='fzf-tmux-session-window'
  else
    alias tmsw='tmux-session-window'
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
  typeset -xT TREE tree ' '
  tree=(-F -l -v --dirsfirst --filelimit 10000 -C -L 5)
  function tree {
    emulate -LR zsh
    local -a opts=( "$@" )
    local -T TREE="${TREE}" tree " "
    local -a base=( -F -l -v --dirsfirst --filelimit 10000 --gitignore )
    local ignore_from=( "${XDG_CONFIG_HOME:-${HOME}/.config}"/git/ignore(-.N) )
    local ignore_list=( "${(f)$(< "${ignore_from[@]-/dev/null}")}" ) 2> /dev/null
    if test "${#ignore_list[@]}" -gt 0; then
      base+=( -I "(${(j:|:)ignore_list[@]%%(\/##\*#)#})" "${opts[@]}" )
    fi
    command tree "${base[@]}" "${tree[@]}" "${opts[@]}"
  }
fi


# date-iso - print the date and time in ISO 8601 format up to the given precision (default: seconds)
# usage: date-iso [date|hours|minutes|seconds|ns]
function date-iso () {
  date --iso-8601="${1-seconds}" "${@:2}"
}


# du-tree - show a summary of disk usage for a directory tree - from root to leaves
# usage: du-tree [du-options] directory
function du-tree () {
  emulate -LR zsh
  local root
  local -a -U du_options=(--dereference-args --human-readable --total)
  if test "$#" -lt 1
  then
    >&2 printf 'usage: du-tree [du-options] directory\n' 
    return 2
  fi
  root="${@[-1]}"
  du_options+=("${@:1:-1}")
  du "${du_options[@]}" "${root}" | sort -h -b --key "1,1"
}


# Close file descriptors and spin up background processes with
# end-of-line aliases
alias -g '@='='< /dev/null > /dev/null 2>&1'
alias -g '@+'='< /dev/null > /dev/null 2>&1 &'
alias -g '@!'='< /dev/null > /dev/null 2>&1 &!'


# Launch and forget you even started a command in the background.
# Try to close all the file descriptors connected to a terminal.
# Redirect stidin/stdout/stderr to pipes if you want to provide
# input or capture output.
emulate -R zsh -c 'function forkforget() (
  local fdlist=( 0 1 2 ) 
  local tydir=""
  local ty
  local fd
  if test -d "/proc/$$/fd"; then
    tydir="/proc/$$/fd"
  elif ty="$(tty)"; then
    tydir="${ty##*/}"
  fi
  if test -n "${tydir}"; then
    for fd in "${tydir}"/*; do
      fd="${fd##*/}"
      if ! [[ "${fd}" == *[^0-9]* ]]; then
        fdlist+=( "${fd}" )
      fi
    done
  fi
  for fd in "${fdlist[@]}"; do
    if test -t "${fd}"; then
      exec {fd}>&-
    fi
  done
  "$@" &|
)'

# vi:et:sts=2:sw=2:tw=0:ft=zsh
