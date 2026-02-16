# clipboard-keybindings.plugin.zsh: define and bind copy-paste ZLE widgets

# Copy the line editor buffer contents
#
_zclipcopy() {
  printf '%s' "${BUFFER}" | clipcopy
}
zle -N _zclipcopy
bindkey -M emacs '^[-' _zclipcopy


# Paste the clipboard contents
#
_zclippaste() {
  if LBUFFER="${LBUFFER}$(clippaste)"; then
    zle redisplay
    if typeset -f zle-line-init >/dev/null; then
      zle zle-line-init
    fi
  fi
}

zle -N _zclippaste
bindkey -M emacs '^[+' _zclippaste


# Quote the clipboard contents in-place
#
_zclipquote() {
  printf '%q' "$(clippaste)" | clipcopy
}
zle -N _zclipquote
bindkey -M emacs "^['" _zclipquote
