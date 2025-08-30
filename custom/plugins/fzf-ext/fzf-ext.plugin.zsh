#!/usr/bin/env zsh
# see fzf(1), rg(1)


# Kill processes
function fzkill() {
  emulate -LR zsh
  local usage='fzkill [-s SIG_NAME] SEARCH'
  local fzf=("${(z)$(__fzfcmd):-fzf}")
  local ps=(ps -e -o user,pid,ppid,start,tty,time,command=CMD)
  local kill_prefix=(kill)
  local kill_signal="KILL"
  local opt
  while getopts ':hs:' opt; do
    case "${opt}" in
      'h')
        >&2 printf 'usage: %s\n' "${usage}"
        return 0
        ;;
      's')
        kill_signal="${OPTARG}"
        ;;
      '?')
        >&2 printf 'fzkill: -%c: invalid option\n' "${OPTARG}"
        >&2 printf 'usage: %s\n' "${usage}"
        return 2
        ;;
      ':')
        >&2 printf 'fzkill: -%c: missing required argument\n' "${OPTARG}"
        >&2 printf 'usage: %s\n' "${usage}"
        return 2
        ;;
    esac
  done
  shift "$((OPTIND - 1))"
  if test "$#" -gt 1; then
    >&2 printf 'fzkill: too many arguments\n' "${usage}"
    >&2 printf 'usage: %s\n' "${usage}"
    return 2
  fi
  kill_prefix+=(-s "${kill_signal}")
  fzf+=(
    --multi
    --accept-nth=2
    --header-lines=1
    --bind='enter:accept'
    --bind='ctrl-r:reload('"${ps}"')'
    --bind='ctrl-x:execute('"${kill_prefix}"' {+2})+clear-multi+reload('"${ps}"')'
    --header='<Tab> to Select / <Ctrl-X> to Kill / <Ctrl-R> to Reload / <Enter> to Print / <Esc> to Abort'
    --preview='top -pid {2}'
    --preview-window='down,25%,follow,nowrap,noinfo'
    --query "$1"
  )
  "${(@)ps}" | FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS}" "${(@)fzf}"
}


# Find files (ripgrep)
function fzgrep() {
  emulate -LR zsh
  setopt extendedglob
  local -xT FZF_DEFAULT_COMMAND fzf_default_command=("${(q)rg[@]}" '--files-with-matches' '--' "${(q)@}") ' '
  local rg=(rg --color=never --no-column --no-heading --hidden --no-line-number)
  local fzf=("${(z)$(__fzfcmd):-fzf}")
  local preview=(cat -b)
  local IFS=$' \t\n'

  if test "$#" -lt 1; then
    >&2 print -f 'usage: %s SEARCH [PATH ...]\n' -- "$0"
    return 2
  fi 

  if command -v bat; then
    preview=(bat --color='always' --paging='never' --style='auto')
  elif command -v nvimpager; then
    preview=(nvimpager -c --)
  elif command -v highlight; then
    case "${TERM}" in
      ((allacrity|linux|st|vte|xterm|kitty|iterm2|tmux)(-*)#)
        preview=(highlight --force --line-numbers --wrap-no-numbers --out-format='truecolor')
        ;;
      (*-256color(-*)#)
        preview=(highlight --force --line-numbers --wrap-no-numbers --out-format='xterm256')
        ;;
      esac
  fi > /dev/null

  fzf+=(
    --bind="change:reload:${${(q)rg[@]}[*]} --files-with-matches -- {q} ${2+${(q)@:2}}"
    --query="${1:+${(q)1}}"
    --disabled
    --bind='ctrl-j:replace-query+print-query'
    --bind='ctrl-k:kill-line'
    --bind='ctrl-c:abort'
    --bind='ctrl-x:execute-silent%open -- {}%'
    --bind='alt-x:become%'"${EDITOR:-vi}"' -- {}%'
    --border='sharp'
    --preview-window='top:60%'
    --layout='reverse-list'
    --preview="{
      ${${(q)preview[@]}[*]} -- {} |
        ${${(q)rg[@]}[*]} --color=always --passthru -- {q} ||
        ${${(q)rg[@]}[*]} --color=always --passthru -- {q} {}
    } 2> /dev/null"
  )
  "${fzf[@]}"
}

# find man pages
fzman () {

  emulate -LR zsh

  local -xT FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS}" fzf_default_opts ' '
  local -xT FZF_DEFAULT_COMMAND="${FZF_DEFAULT_COMMAND}" fzf_default_command ' '
  local -a fzf=(
    fzf
    --bind="change:reload:man -k -- {q}"
    --query="${1:+${(q)1}}"
    --phony
    --preview='man -- {1}'
  )
  local selected=''
  local IFS=$' \t\n'

  if ! (( $# )); then
    >&2 print -f 'usage: %s SEARCH\n' -- "$0"
    return 2
  fi 

  if (( ${+tmux_pane} && ${fzf_tmux-0} && ${LINES:-40} > 20 )); then
    fzf[1,1]=(fzf-tmux -d "${fzf_tmux_height:-40%}" "${fzf[@]}")
  fi

  fzf_default_opts+=(
    --bind="'"'ctrl-j:replace-query+print-query'"'"
    --bind="'"'ctrl-k:kill-line'"'"
    --bind="'"'ctrl-c:abort'"'"
    --border="'"'sharp'"'"
    --preview-window="'"'top:54%'"'"
    --layout="'"'reverse-list'"'"
  )

  fzf_default_command=(
    'man' '-k' '--' "${(q)@}"
  )

  if [[ -n "${selected::=$("${fzf[@]}")}" ]]; then
    man -- "${selected}"
  fi
}
