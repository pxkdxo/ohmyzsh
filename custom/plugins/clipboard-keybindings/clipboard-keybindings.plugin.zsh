# clipboard-keybindings.plugin.zsh: define and bind copy-paste ZLE widgets

_zclipcopy() {
  printf '%s' -- "${BUFFER}" | clipcopy
}

_zclippaste() {
  if LBUFFER="${LBUFFER}$(clippaste)"; then
    zle redisplay
    if typeset -f zle-line-init >/dev/null; then
      zle zle-line-init
    fi
  fi
}

zle -N _zclipcopy
bindkey -M emacs '^[-' _zclipcopy

zle -N _zclippaste
bindkey -M emacs '^[+' _zclippaste
