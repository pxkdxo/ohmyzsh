# zsh parameters
# see zshparam(1)

typeset -g LISTMAX=0
typeset -g DIRSTACKSIZE=10
typeset -g CORRECT_IGNORE='_*'
typeset -g CORRECT_IGNORE_FILE='*~'
typeset -g HISTSIZE=25000
typeset -g SAVEHIST=10000
typeset -g HISTORY_IGNORE='[[:blank:]]#(fg|bg|exit|clear)([[:blank:]]##[^[:space:]]##)#[[:blank:]]#(|[;&|])[[:blank:]]#'
typeset -g NULLCMD="${NULLCMD:-:}"
typeset -g READNULLCMD="${READNULLCMD:-${PAGER:-cat}}"
typeset -g PROMPT_EOL_MARK='%1F %f'
typeset -g -H SPROMPT='%N: %1F%U%R%u%f: perhaps you meant %2F%U%r%u%f [%By%b/%Bn%b/%Be%b/%Ba%b]: '

zshaddhistory() {
  emulate -L zsh
  setopt extendedglob
  [[ $1 != ${HISTORY_IGNORE} ]]
}
