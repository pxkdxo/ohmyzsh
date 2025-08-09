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
alias df='df -h'
alias dfx='df -x tmpfs -x devtmpfs -x squashfs'
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
alias nvim='nvim -p'
alias rm='rm -Iv'
alias rmdir='rmdir -v'
alias vdir='vdir --color=auto'
alias vim='vim -p'


# ``tree'' customization
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


# expand aliases following sudo
alias sudo='sudo '


# help
alias run-help='run-help '
alias help='run-help'


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
alias L='ls -L'
alias l1='ls -1'
alias L1='ls -1L'
alias ll='ls -l'
alias Ll='ls -Ll'
alias la='ls -A'
alias La='ls -AL'
alias lla='ls -Al'
alias Lla='ls -ALl'
alias lr='ls -R'
alias Lr='ls -LR'
alias lar='ls -AR'
alias Lar='ls -ALR'
alias lt='ls -1t'
alias Lt='ls -1Lt'
alias lat='ls -1At'
alias Lat='ls -1ALt'
alias llat='ls -Alt'
alias Llat='ls -ALlt'
alias dls='ls -dl'


# man
alias m='man'


# ps
alias p='ps c w -fj' 
alias psa='ps w -afj'
alias pse='ps w -efj'
alias psat='ps w -afj -t "${TTY:-$(tty)}"'
alias psau='ps w -afj -u "${UID:-$(id -u)}"'
alias pset='ps w -efj -t "${TTY:-$(tty)}"'
alias pseu='ps w -efj -t "${UID:-$(id -u)}"'


# python
alias py='python'
alias py3='python3'
alias py2='python2'


# vim / neovim
alias v='vim'
alias nvimdiff='command nvim -d'


# thefuck
if command -v fuck > /dev/null; then
  alias fk='fuck'
fi


# htop
if command -v htop > /dev/null; then
  alias top='htop'
fi


# tmux
if command -v tmux > /dev/null; then
  alias t='tmux'
  alias tns='tmux new-session'
  alias tnw='tmux new-window'
  alias ta='tmux attach-session'
  function tmux-attach-new-session-window() {
    emulate -L zsh
    fzf=("${(z)$(__fzfcmd):-fzf}")
    session_group="${1-$(
      tmux list-sessions -F "#{session_group}" | sort -u |
      FZF_DEFAULT_OPTS="--height=${(q)FZF_TMUX_HEIGHT:-20%} ${FZF_DEFAULT_OPTS} --cycle -1" "${fzf[@]}"
    )}"
    [[ -n ${session_group} ]] && tmux new -d -t "${session_group}" ";" "new-window" ";" "attach"
  }
  alias tnsw='tmux-attach-new-session-window'
fi


# xclip
if [[ "${XDG_SESSION_TYPE-}" == "wayland" ]]; then
  if command -v "wl-copy" > /dev/null && command -v "wl-paste" > /dev/null; then
    alias pbcopy="wl-copy --trim-newline"
    alias pbpaste="wl-paste"
    alias pbdropfmt="pbpaste | pbcopy"
  fi
else
  if command -v "xclip" > /dev/null; then
    alias pbcopy="xclip -selection clipboard"
    alias pbpaste="xclip -selection clipboard -o"
    alias pbdropfmt="pbpaste | pbcopy"
  fi
fi


# feh
if command -v feh > /dev/null; then
  alias feh-show='feh --auto-zoom --image-bg black --slideshow-delay 8'
fi


# query DNS servers for my WAN IP
alias wanip4='dig @resolver1.opendns.com -4 myip.opendns.com +short'
alias wanip6='dig @resolver1.opendns.com -6 myip.opendns.com +short'
alias wanip='wanip4'


# print the number of arguments supplied
function nargs() {
  print "$#"
}
