# zshaliases.plugin.zsh: Define aliases for an interactive shell
#
# vim : set et ft=zsh sts=2 sw=2 tw=0 :

# If this is not an interactive shell, abort.
case $- in
  (*i*) ;;
    (*) return ;;
esac


# default command options
alias cp='cp -iv'
alias df='df --exclude-type=tmpfs --exclude-type=devtmpfs --exclude-type=squashfs -h'
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
alias vim='vim -p'


# expand aliases following sudo
alias sudo='sudo '


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
typeset -gT PS_FORMAT="user,pid,ppid,pgid,sess,jobc,tt,stat,start,time,command=CMD" ps_format ,
alias p='ps -o "${PS_FORMAT:=user,pid,ppid,pgid,sess,jobc,tt,stat,start,time,command=CMD}"'
alias pa='p -a'
alias px='p -x'
alias pe='p -e'


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
  alias nvim='nvim -p'
  alias nvimdiff='nvim -d'
  alias vimdiff='nvimdiff'
fi


# thefuck
if command -v fuck > /dev/null; then
  alias f='fuck'
fi


# top
if command -v btm > /dev/null; then
  alias top='btm'
elif command -v gtop > /dev/null; then
  alias top='gtop'
elif command -v htop > /dev/null; then
  alias top='htop'
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
    local ignore_from=("${XDG_CONFIG_HOME:-${HOME}/.config}"/git/ignore(-.N) .gitignore(.N))
    local ignore_list=("${(f)$(< "${ignore_from[@]-/dev/null}")}") 2> /dev/null
    local options=(-CFlvI "(${(j:|:)ignore_list[@]%%(\/##\*#)#})")
    if (( ${+TREE} )); then
      options=("${(z)TREE}")
    fi
    command tree "${options[@]}" "$@"
  }
fi


# date.iso - print the date and time up to the given precision (format: ISO 8601)
# usage: date.iso [date|hours|minutes|seconds|ns]
date.iso () {
	date "-I${1-}"
}
