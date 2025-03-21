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
alias nvim='nvim -p'
alias df='df -h'
alias dfx='df -x tmpfs -x devtmpfs -x squashfs'


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
alias mw='man --wildcard'
alias mx='man --regex'
alias mk='man --apropos'
alias mkw='man --apropos --wildcard'
alias mf='man --whatis'
alias mfx='man --whatis --regex'


# ps
alias p='ps c w -fj' 
alias psa='ps w -afj'
alias pse='ps w -efj'
alias psat='ps w -afj -t "${TTY:-$(tty)}"'
alias pset='ps w -efj -t "${TTY:-$(tty)}"'


# python
alias py='python'
alias py3='python3'
alias py2='python2'


# vim / neovim
alias v='vim'
alias nvimdiff='command nvim -d'
if command -v nvim > /dev/null; then
  alias vim='nvim'
  alias vimdiff='nvimdiff'
fi


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
  function tnsw() {
    emulate -L zsh
    local fzf=("${(z)$(__fzfcmd):-fzf}")
    local session_group="${1-$(
    tmux list-sessions -F "#{session_group}" | sort -u | FZF_DEFAULT_OPTS="--cycle --height=${(q)FZF_TMUX_HEIGHT:-20%} ${FZF_DEFAULT_OPTS} -1" "${fzf[@]}"
    )}"
    if [[ -n ${session_group} ]]; then
      tmux new -d -t "${session_group}" ";" new-window ";" attach
    fi
  }
fi


# xclip
if [[ "${XDG_SESSION_TYPE-}" == "wayland" ]]; then
  if command -v "wl-copy" > /dev/null && command -v "wl-paste" > /dev/null; then
    alias cbcopy="wl-copy --trim-newline"
    alias cbpaste="wl-paste"
    alias cbclfmt="cbpaste | cbcopy"
  fi
else
  if command -v "xclip" > /dev/null; then
    alias cbcopy="xclip -selection clipboard"
    alias cbpaste="xclip -selection clipboard -o"
    alias cbclfmt="cbpaste | cbcopy"
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


# youtube-dl
if command -v youtube-dl > /dev/null; then
  typeset -xT YTDL_OPTS ytdl_opts ' '
  ytdl_opts=(
    '--geo-bypass'
    '--ignore-errors'
    '--max-sleep-interval=5'
    '--min-sleep-interval=1'
  )
  typeset -xT YTDLA_OPTS ytdla_opts ' '
  ytdla_opts=(
    '--add-metadata'
    '--extract-audio'
    '--playlist-random'
    '--audio-quality=0'
    '--metadata-from-title='"'"'^\s*(?:(?P<artist>.+?)(?:\s+[Ff]t\.?|[Ff]eat(?:\.|uring)?\s.+?)?\s+[~|=/+-]+\s+(?:(?P<album>.+?)\s+[~|=/+-]+\s+)?)?(?P<title>.+?)(?:\s+(?:[([](?:\s*(?:[Aa      ]udio|[Ll]yrics?|[Mm]usic|[Oo]nly|(?:[Uu]n)?[Oo]fficial|[Vv]ideo)\s*)+[])])+\s*)*\s*$'"'"
    '--output="${XDG_MUSIC_DIR:-${HOME}/Music}/%(title)s.%(id)s.%(ext)s"'
  )
  alias youtube-dl="youtube-dl ${YTDL_OPTS}"
  alias ytdl="youtube-dl"
  alias ytdla="youtube-dl ${YTDLA_OPTS}"
fi


# print the number of arguments supplied
function nargs() {
  print "$#"
}
