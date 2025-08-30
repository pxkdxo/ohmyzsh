globalias() {
  zle _expand_alias
  zle expand-word
  zle magic-space
}
zle -N globalias

# press alt-space to expand all aliases
bindkey -M emacs "^[ " globalias
bindkey -M viins "^[ " globalias

# press space to insert a normal space
bindkey -M emacs " " magic-space
bindkey -M viins " " magic-space

# press space to insert a normal space while searching
bindkey -M isearch " " magic-space
