# clipboard-keybindings.plugin.zsh: define and bind copy-paste ZLE widgets

function clipboard-copy() {
  clipcopy <<< "${BUFFER}"
}

function clipboard-paste() {
  local temp=""
  read -
  if ! temp="$(clippaste)"; then
    return "$?"
  fi
  # Strip whitespace
  temp="${temp#"${temp%%[^[:space:]]*}"}"
  temp="${temp%"${temp##*[^[:space:]]}"}"
  # Update line editor
  RBUFFER="${temp}${RBUFFER}" 
  zle redisplay
  if typeset -f zle-line-init >/dev/null; then
    zle zle-line-init
  fi
}

zle -N clipboard-copy
bindkey -M emacs '^[-' clipboard-copy
bindkey -M viins '^[-' clipboard-copy

zle -N clipboard-paste
bindkey -M emacs '^[+' clipboard-paste
bindkey -M viins '^[+' clipboard-paste
