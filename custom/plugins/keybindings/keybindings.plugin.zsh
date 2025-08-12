# custom zle keybindings

bindkey " "       magic-space

bindkey "^I"      expand-or-complete
bindkey "^[[Z"    reverse-menu-complete

bindkey "^[[1;3D" backward-word
bindkey "^[[1;4D" backward-word
bindkey "^[[1;5D" backward-word
bindkey "^[^[[D"  backward-word

bindkey "^[[1;3C" forward-word
bindkey "^[[1;4C" forward-word
bindkey "^[[1;5C" forward-word
bindkey "^[^[[C"  forward-word

bindkey "^[[1;3B" down-history
bindkey "^[^[[B"  down-history
bindkey "^[[1;3A" up-history
bindkey "^[^[[A"  up-history

bindkey "^[[1;5A" history-beginning-search-backward
bindkey "^[[1;5B" history-beginning-search-forward

bindkey "^[[B"    down-line-or-history
bindkey "^[OB"    down-line-or-history

bindkey "^[[A"    up-line-or-history
bindkey "^[OA"    up-line-or-history

#bindkey "^r"      history-incremental-pattern-search-backward
bindkey "^Xr"     history-incremental-pattern-search-backward
#bindkey "^S"      history-incremental-pattern-search-forward
bindkey "^Xs"     history-incremental-pattern-search-forward

bindkey "^[[7~"   beginning-of-line                               # Home key
bindkey "^[[H"    beginning-of-line                               # Home key
if [[ "${terminfo[khome]}" != "" ]]; then
  bindkey "${terminfo[khome]}" beginning-of-line                  # [Home]
fi
bindkey "^[[8~"  end-of-line                                      # End key
bindkey "^[[F"   end-of-line                                      # End key
if [[ "${terminfo[kend]}" != "" ]]; then
  bindkey "${terminfo[kend]}" end-of-line                         # [End]
fi
