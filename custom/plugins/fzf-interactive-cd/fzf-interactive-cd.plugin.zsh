# Copyright (c) 2017 Henry Chang

__zic_fzf_prog() {
  [ -n "$TMUX_PANE" ] && [ "${FZF_TMUX:-0}" != 0 ] && [ ${LINES:-40} -gt 15 ] \
    && echo "fzf-tmux -d${FZF_TMUX_HEIGHT:-40%}" || echo "fzf"
}

__zic_matched_subdir_list() {
  emulate -LR zsh
  print -f '%s\n' "$1"*(-/N:t)
}

_zic_list_generator() {
  __zic_matched_subdir_list "$1" | sort
}

_zic_complete() {
  setopt localoptions nonomatch
  local l q matches fzf tokens base

  q="${(Q)@[-1]}"

  l=$(_zic_list_generator "$q")

  if [ -z "$l" ]; then
    return 1
  fi

  if [ $(echo $l | wc -l) -eq 1 ]; then
    matches=${(q)l}
    return 1
  fi

  fzf=$(__zic_fzf_prog)
  matches=$(echo $l \
      | FZF_DEFAULT_OPTS="--height=${FZF_TMUX_HEIGHT:-40%} --reverse \
        $FZF_DEFAULT_OPTS $FZF_COMPLETION_OPTS $FZF_INTERACTIVE_CD_OPTS \
        --bind 'shift-tab:up,tab:down' --query=${(q)q##*/}" ${=fzf} \
      | while read -r item; do
    echo -n "${(q)item} "
  done)

  matches=${matches% }
  if [ -n "$matches" ]; then
    tokens=(${(z)LBUFFER})
    base="${(Q)@[-1]}"
    if [[ "$base" != */ ]]; then
      if [[ "$base" == */* ]]; then
        base="$(dirname -- "$base")"
        if [[ ${base[-1]} != / ]]; then
          base="$base/"
        fi
      else
        base=""
      fi
    fi
    LBUFFER="${tokens[1]} "
    if [ -n "$base" ]; then
      base="${(q)base}"
      if [ "${tokens[2][1]}" = "~" ]; then
        base="${base/#$HOME/~}"
      fi
      LBUFFER="${LBUFFER}${base}"
    fi
    LBUFFER="${LBUFFER}${matches}/"
  fi
  zle redisplay
  if typeset -f zle-line-init >/dev/null; then
    zle zle-line-init
  fi
  return 0
}

zic-completion() {
  setopt localoptions localtraps noshwordsplit noksh_arrays noposixbuiltins
  local tokens cmd

  tokens=("${(z)LBUFFER}")
  cmd="${tokens[1]}"

  if [[ "${LBUFFER}" =~ $'^[ \t]*(\\\\?cd|\'cd\'|"cd")$' ]]; then
    zle "${__zic_default_completion:-expand-or-complete}"
  elif [[ "${(Q)cmd}" = cd ]]; then
    zle complete-word
    if [[ "${tokens[*]:1}" == "${${(@A)tokens::=${(z)LBUFFER}}[*]:1}" ]]; then
      if _zic_complete "${tokens[2,-1]/#\~/$HOME}"; then
        zle auto-suffix-retain
        zle -R
        while [[ "${tokens[*]:1}" != "${${(@A)tokens::=${(z)LBUFFER}}[*]:1}" ]]; do
          if _zic_complete "${tokens[2,-1]/#\~/$HOME}"; then
            zle auto-suffix-retain
            zle -R 
          else
            zle auto-suffix-retain
            zle -R 
            break
          fi
        done
      else
        zle "${__zic_default_completion:-expand-or-complete}"
      fi
    fi
    return
  else
    zle "${__zic_default_completion:-expand-or-complete}"
  fi
} 

[ -z "$__zic_default_completion" ] && {
  binding=$(bindkey '^I')
  # $binding[(s: :w)2]
  # The command substitution and following word splitting to determine the
  # default zle widget for ^I formerly only works if the IFS parameter contains
  # a space via $binding[(w)2]. Now it specifically splits at spaces, regardless
  # of IFS.
  [[ $binding =~ 'undefined-key' ]] || __zic_default_completion=$binding[(s: :w)2]
  unset binding
}

zle -N zic-completion
bindkey -M emacs '^I' zic-completion
bindkey -M viins '^I' zic-completion
