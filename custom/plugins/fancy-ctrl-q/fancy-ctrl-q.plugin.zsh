# List and resume background jobs
#
# Standarized way of handling finding plugin dir,
# regardless of functionargzero and posixargzero,
# and with an option for a plugin manager to alter
# the plugin directory (i.e. set ZERO parameter)
# https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

#_fancy_ctrl_q
# Resume last stopped job or list jobs if command line is not empty
_fancy_ctrl_q() {
  if test -z "${BUFFER}"; then
    BUFFER="builtin bg %+"
    zle accept-line -w
  else
    zle push-input -w
    BUFFER="jobs -l"
    zle accept-line -w
    zle pop-input -w
  fi
}
zle -N _fancy_ctrl_q
bindkey "^Q" _fancy_ctrl_q


# zsh-autosuggestions: convenient accept and toggle if plugin is loaded
if (( ${+functions[_zsh_autosuggest_bind_widgets]} )) || [[ -n ${ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE:+x} ]]
then
  # Accept suggestion with Ctrl-Right (xterm/iterm CSI 1;5C) and with End
  bindkey '^[[1;5C' autosuggest-accept 2>/dev/null || true
  bindkey '^[OC' autosuggest-accept 2>/dev/null || true
  bindkey '^[OF' autosuggest-accept 2>/dev/null || true
  bindkey '^E' autosuggest-accept 2>/dev/null || true
fi
