# custom zle keybindings

function _fancy_ctrl_q() {
  if [[ ${#BUFFER} -eq 0 ]]
  then
    BUFFER="builtin bg %+"
    zle accept-line -w
  else
    zle push-input -w
    zle clear-screen -w
    BUFFER="jobs -l"
    zle accept-line -w
    zle pop-input -w
  fi
}
zle -N _fancy_ctrl_q
bindkey "^Q" _fancy_ctrl_q

# zsh-autosuggestions: convenient accept and toggle if plugin is loaded
if (( $+functions[_zsh_autosuggest_bind_widgets] )) || [[ -n ${ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE:+x} ]]
then
  # Accept suggestion with Ctrl-Right (xterm/iterm CSI 1;5C) and with End
  bindkey '^[[1;5C' autosuggest-accept 2>/dev/null || true
  bindkey '^[OC' autosuggest-accept 2>/dev/null || true
  bindkey '^[OF' autosuggest-accept 2>/dev/null || true
  bindkey '^E' autosuggest-accept 2>/dev/null || true
fi

bindkey " " magic-space
bindkey "^B" backward-kill-word
bindkey "^F" kill-word
bindkey "^M" accept-line
bindkey "^Xr" history-incremental-pattern-search-backward
bindkey "^Xs" history-incremental-pattern-search-forward
bindkey "^Y" yank
bindkey "^[*" list-expand
bindkey "^[OA" up-line-or-history
bindkey "^[OB" down-line-or-history
bindkey "^[Y" yank-pop
bindkey "^[[" get-line
bindkey "^[[127;2u" backward-delete-char
bindkey "^[[127;5u" backward-kill-line
# Avoid duplicate binding for the same key sequence
bindkey "^[[13;2u" accept-line
bindkey "^[[1;2A" up-history
bindkey "^[[1;2B" down-history
bindkey "^[[1;2C" forward-word
bindkey "^[[1;2D" backward-word
bindkey "^[[1;3A" up-history
bindkey "^[[1;3B" down-history
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^[[1;4A" history-beginning-search-backward
bindkey "^[[1;4B" history-beginning-search-forward
bindkey "^[[1;4C" forward-word
bindkey "^[[1;4D" backward-word
bindkey "^[[1;5A" history-beginning-search-backward
bindkey "^[[1;5B" history-beginning-search-forward
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[[27;2u" run-help
bindkey "^[[32;2u" magic-space
bindkey "^[[7~" beginning-of-line
bindkey "^[[8~" end-of-line
bindkey "^[[A" up-line-or-history
bindkey "^[[B" down-line-or-history
bindkey "^[[F" end-of-line
bindkey "^[[H" beginning-of-line
bindkey "^[[Z" reverse-menu-complete
bindkey "^[]" push-line
bindkey "^[^[[A" up-history
bindkey "^[^[[B" down-history
bindkey "^[^[[C" forward-word
bindkey "^[^[[D" backward-word
bindkey "^^" redo
bindkey "^_" undo
if [[ -v terminfo[khome] && -n "${terminfo[khome]}" ]]
then
  bindkey "${terminfo[khome]}" beginning-of-line
fi
if [[ -v terminfo[kend] && -n "${terminfo[kend]}" ]]
then
  bindkey "${terminfo[kend]}" end-of-line
fi

# Menu selection navigation: enable hjkl and common abort keys when in completion menu
bindkey -M menuselect 'h' backward-char
bindkey -M menuselect 'j' down-line-or-history
bindkey -M menuselect 'k' up-line-or-history
bindkey -M menuselect 'l' forward-char
bindkey -M menuselect '^G' send-break
bindkey -M menuselect '^[' send-break
bindkey -M menuselect '^[^[' send-break
