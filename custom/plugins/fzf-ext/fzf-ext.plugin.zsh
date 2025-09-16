#!/usr/bin/env zsh
# see fzf(1), rg(1)


# Kill processes
function fz-kill() {
  emulate -LR zsh
  local usage='fz-kill [-s SIG_NAME] [INITIAL_SEARCH]'
  local fzf=("${(z)$(__fzfcmd):-fzf}")
  local ps=(ps -e -o user,pid,start,tty,time,command=CMD)
  local kill_cmd=(kill)
  local kill_sig="TERM"
  local opt
  while getopts ':hs:' opt; do
    case "${opt}" in
      'h')
        printf 'usage: %s\n' "${usage}"
        return 2
        ;;
      's')
        kill_sig="${OPTARG}"
        ;;
      '?')
        >&2 printf 'fz-kill: -%c: invalid option\n' "${OPTARG}"
        >&2 printf 'usage: %s\n' "${usage}"
        return 2
        ;;
      ':')
        >&2 printf 'fz-kill: -%c: missing required argument\n' "${OPTARG}"
        >&2 printf 'usage: %s\n' "${usage}"
        return 2
        ;;
    esac
  done
  shift "$((OPTIND - 1))"
  if test "$#" -gt 1; then
    >&2 printf 'fz-kill: too many arguments\n'
    >&2 printf 'usage: %s\n' "${usage}"
    return 2
  fi
  kill_cmd+=('-s' "${kill_sig}")
  fzf+=(
    --multi
    --accept-nth=2
    --header-lines=1
    --header="* [Select Process: <Tab>] [Kill Selected: <C-x>] [Refresh Processes: <C-r>] [Print Selection & Exit: <Return>] [Clear Selection & Exit: <Esc>] *"
    --bind='enter:accept'
    --bind='ctrl-x:execute('"${(j: :)${(q)kill_cmd[@]}}"' {+2})+clear-multi+reload('"${(j: :)${(q)ps[@]}}"')'
    --bind='change:reload('"${(j: :)${(q)ps[@]}}"')'
    --bind='ctrl-r:reload('"${(j: :)${(q)ps[@]}}"')'
    --bind='ctrl-/:change-preview-window(down,25%,follow,nowrap,noinfo|hidden)'
    --preview='top -pid {2}'
    --preview-window='hidden'
    --wrap
  )
  if test "$#" -eq 1; then
    fzf+=('--query' "$1")
  fi
  "${ps[@]}" | "${fzf[@]}"
}


# Find files (ripgrep)
function fz-grep() {
  emulate -LR zsh
  setopt extendedglob

  local -xT FZF_DEFAULT_COMMAND fzf_default_command=() ' '
  local usage='fz-grep [PATTERN [PATH [...]]]'
  local fzf=("${(z)$(__fzfcmd):-fzf}")
  local rg=(rg --no-column --no-heading --color=never --hidden --follow)
  local preview=(cat -b)
  local opt
  while getopts ':h:' opt; do
    case "${opt}" in
      'h')
        printf 'usage: %s\n' "${usage}"
        return 2
        ;;
      '?')
        >&2 printf 'fz-kill: -%c: invalid option\n' "${OPTARG}"
        >&2 printf 'usage: %s\n' "${usage}"
        return 2
        ;;
      ':')
        >&2 printf 'fz-kill: -%c: missing required argument\n' "${OPTARG}"
        >&2 printf 'usage: %s\n' "${usage}"
        return 2
        ;;
    esac
  done
  shift "$((OPTIND - 1))"
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

  fzf_default_command=("${(q)rg[@]}" --files-with-matches -- "${1-.+}" "${(q)@:2}")
  fzf+=(
    --disabled
    --query="${1-.+}"
    --bind="change:reload:${(j: :)${(q)rg[@]}} --files-with-matches -- {q} ${(j: :)${(q)@:2}}"
    --bind='ctrl-j:replace-query+print-query'
    --bind='ctrl-k:kill-line'
    --bind='ctrl-c:abort'
    --bind='ctrl-x:execute-silent%open -- {}%'
    --bind='alt-x:become%'"${EDITOR:-vi}"' -- {}%'
    --border='sharp'
    --preview-window='top:60%'
    --layout='reverse-list'
    --preview="{
      ${(j: :)${(q)preview[@]}} -- {} |
        ${(j: :)${(q)rg[@]}} --color=always --passthru -- {q} ||
        ${(j: :)${(q)rg[@]}} --color=always --passthru -- {q} {}
    } 2> /dev/null"
  )
  "${fzf[@]}"
}

# find man pages
function fz-man () {
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

