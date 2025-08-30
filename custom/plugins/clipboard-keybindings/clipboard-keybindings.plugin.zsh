# clipboard-keybindings.plugin.zsh: define and bind copy-paste ZLE widgets

function _zclipcopy() {
  printf '%s' -- "${BUFFER}" | clipcopy
  return 0
}

function _zclippaste() {
  local temp
  if LBUFFER="${LBUFFER}$(clippaste)"; then
    zle redisplay
    if typeset -f zle-line-init >/dev/null; then
      zle zle-line-init
    fi
  fi
  return 0
}

zle -N _zclipcopy
bindkey -M emacs '^[-' _zclipcopy
bindkey -M viins '^[-' _zclipcopy

zle -N _zclippaste
bindkey -M emacs '^[+' _zclippaste
bindkey -M viins '^[+' _zclippaste
