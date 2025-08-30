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

bindkey "^M" accept-line
bindkey "^[[13;2u" accept-line
bindkey -s "^[[106;5u" "
"

bindkey " " magic-space
bindkey "^[[32;2u" magic-space

bindkey "^I" expand-or-complete
bindkey "^[[Z" reverse-menu-complete

bindkey "^Y" yank
bindkey "^[Y" yank-pop
bindkey "^_" undo
bindkey "^^" redo

bindkey "^F" kill-word
bindkey "^B" backward-kill-word

bindkey "^[^[[C" forward-word
bindkey "^[[1;2C" forward-word
bindkey "^[[1;3C" forward-word
bindkey "^[[1;4C" forward-word
bindkey "^[[1;5C" forward-word
bindkey "^[^[[D" backward-word
bindkey "^[[1;2D" backward-word
bindkey "^[[1;3D" backward-word
bindkey "^[[1;4D" backward-word
bindkey "^[[1;5D" backward-word

bindkey "^[[A" up-line-or-history
bindkey "^[OA" up-line-or-history
bindkey "^[[B" down-line-or-history
bindkey "^[OB" down-line-or-history

bindkey "^[[1;2A" up-history
bindkey "^[[1;3A" up-history
bindkey "^[^[[A" up-history
bindkey "^[[1;2B" down-history
bindkey "^[[1;3B" down-history
bindkey "^[^[[B" down-history

bindkey "^[[1;4B" history-beginning-search-forward
bindkey "^[[1;5B" history-beginning-search-forward
bindkey "^[[1;4A" history-beginning-search-backward
bindkey "^[[1;5A" history-beginning-search-backward

bindkey "^Xs" history-incremental-pattern-search-forward
bindkey "^Xr" history-incremental-pattern-search-backward

bindkey "^[[7~" beginning-of-line
bindkey "^[[H" beginning-of-line
if [[ -v terminfo[khome] && -n "${terminfo[khome]}" ]]
then
 bindkey "${terminfo[khome]}" beginning-of-line
fi

bindkey "^[[8~" end-of-line
bindkey "^[[F" end-of-line
if [[ -v terminfo[kend] && -n "${terminfo[kend]}" ]]
then
 bindkey "${terminfo[kend]}" end-of-line
fi

bindkey "^[[13;2u" accept-and-hold

bindkey "^[[27;2u" run-help

bindkey "^[[127;2u" backward-delete-char
bindkey "^[[127;5u" backward-kill-line

bindkey '^[/' list-choices
bindkey "^[*" list-expand

bindkey "^[]" push-line
bindkey "^[[" get-line
