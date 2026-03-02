# ZLE keybindings
#
# Standarized way of handling finding plugin dir,
# regardless of functionargzero and posixargzero,
# and with an option for a plugin manager to alter
# the plugin directory (i.e. set ZERO parameter)
# https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# Soace & tab
bindkey " " magic-space
# bindkey "^[[Z" reverse-menu-complete

# Arrows
bindkey "^[OA" up-line-or-history
bindkey "^[OB" down-line-or-history
bindkey "^[OC" forward-char
bindkey "^[OD" backward-char
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
bindkey "^[[A" up-line-or-history
bindkey "^[[B" down-line-or-history
bindkey "^[[C" forward-char
bindkey "^[[D" backward-char
bindkey "^[^[[A" up-history
bindkey "^[^[[B" down-history
bindkey "^[^[[C" forward-word
bindkey "^[^[[D" backward-word

# Ctrl
bindkey "^^" redo
bindkey "^_" undo

# Keypad
bindkey "^[[7~" beginning-of-line
bindkey "^[[8~" end-of-line
bindkey "^[[H" beginning-of-line
bindkey "^[[8~" end-of-line
bindkey "^[[F" end-of-line

# Meta
bindkey "^[q" push-input
bindkey "^[g" get-line
bindkey "^[]" push-input
bindkey "^[[" get-line

# CSI-u
bindkey "^[[127;2u" backward-delete-char
bindkey "^[[127;5u" backward-kill-line
bindkey "^[[13;2u" accept-line
bindkey "^[[27;2u" run-help
bindkey "^[[32;2u" magic-space

# Two-stroke
bindkey "^x^r" history-incremental-pattern-search-backward
bindkey "^x^s" history-incremental-pattern-search-forward

# Menu selection navigation: enable hjkl and common abort keys when in completion menu
bindkey -M menuselect 'h' backward-char
bindkey -M menuselect 'j' down-line-or-history
bindkey -M menuselect 'k' up-line-or-history
bindkey -M menuselect 'l' forward-char
bindkey -M menuselect '^[' send-break
bindkey -M menuselect '^\' send-break

# zsh-autosuggestions: convenient accept and toggle if plugin is loaded
if (( ${+functions[_zsh_autosuggest_bind_widgets]} )) || [[ -n ${ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE:+x} ]]
then
  # Accept suggestion with Ctrl-Right (xterm/iterm CSI 1;5C) and with End
  bindkey '^[OC'    autosuggest-accept 2>/dev/null || true
  bindkey '^[[1;5C' autosuggest-accept 2>/dev/null || true
  bindkey "^[[8~"   autosuggest-accept 2>/dev/null || true
  bindkey "^[[F"    autosuggest-accept 2>/dev/null || true
fi
