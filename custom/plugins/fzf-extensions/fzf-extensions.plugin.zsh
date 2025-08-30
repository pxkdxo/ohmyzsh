#!/usr/bin/env zsh
# see fzf(1), rg(1)


# find files with ripgrep
function fzg() {

  emulate -LR zsh

  local -xT FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS}" fzf_default_opts ' '
  local -xT FZF_DEFAULT_COMMAND="${FZF_DEFAULT_COMMAND}" fzf_default_command ' '
  local -a rg=(
    rg --color=never --no-column --no-heading --hidden --no-line-number
  )
  local -a fzf=(
    fzf
    --bind="change:reload:${${(q)rg[@]}[*]} --files-with-matches -- {q} ${2+${(q)@:2}}"
    --query="${1:+${(q)1}}"
    --phony
  )
  local -a preview=(
    cat -b
  )
  local IFS=$' \t\n'

  if ! (( $# )); then
    >&2 print -f 'usage: %s SEARCH [PATH ...]\n' -- "$0"
    return 2
  fi 

  if (( ${+tmux_pane} && ${fzf_tmux-0} && ${LINES:-40} > 20 )); then
    fzf[1,1]=(fzf-tmux -d "${fzf_tmux_height:-42%}" "${fzf[@]}")
  fi

  if command -v bat; then
    preview=(bat --color='always' --paging='never' --style='numbers')
  elif command -v highlight && [[ ${TERM} == (*-direct|allacrity|linux|st|tmux|xterm)(|-*) ]]; then
    preview=(highlight --force --line-numbers --wrap-no-numbers --out-format='truecolor')
  elif command -v highlight && [[ ${TERM} == *-256color(|-*) ]]; then
    preview=(highlight --force --line-numbers --wrap-no-numbers --out-format='xterm256')
  fi > /dev/null

  fzf+=(--preview="
  { ${${(q)preview[@]}[*]} -- {} |
    ${${(q)rg[@]}[*]} --color=always --passthru -- {q} ||
    ${${(q)rg[@]}[*]} --color=always --passthru -- {q} {}
  } 2> /dev/null")

  fzf_default_opts+=(
    --bind="'"'ctrl-j:replace-query+print-query'"'"
    --bind="'"'ctrl-k:kill-line'"'"
    --bind="'"'ctrl-c:abort'"'"
    --bind="'"'ctrl-x:execute-silent%rifle -- {}%'"'"
    --bind="'"'alt-x:execute-silent%tmux new-window ranger --selectfile={}%'"'"
    --border="'"'sharp'"'"
    --preview-window="'"'top:54%'"'"
    --layout="'"'reverse-list'"'"
  )

  fzf_default_command=(
    "${(q)rg[@]}" '--files-with-matches' '--' "${(q)@}"
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
