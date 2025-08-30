# zsh parameters
# see zshparam(1)

typeset -g LISTMAX=0
typeset -g DIRSTACKSIZE=10
typeset -g CORRECT_IGNORE='_*'
typeset -g CORRECT_IGNORE_FILE='(.*|*~)'
typeset -g HISTSIZE=9999
typeset -g SAVEHIST=9999
typeset -g HISTORY_IGNORE='([[:blank:]]*|*/...([/;&|[:space:]]*)#)'
typeset -g NULLCMD="${NULLCMD:-cat}"
typeset -g READNULLCMD="${READNULLCMD:-cat}"
typeset -g PROMPT_EOL_MARK='%S#%s'
typeset -ga sprompt=(
  "%N:"
  "%1F'\${\${:-%%R}//'/''''}'%1f:"
  "perhaps you meant"
  "%2F'\${\${:-%%r}//'/''''}'%2f"
  "%8F[%8f%7Fy%7f%8F/%8f%7Fn%7f%8F/%8f%7Fe%7f%8F/%8f%7Fa%7f%8F]%8f: "
)
typeset -gH SPROMPT='${(%%)sprompt[@]}'

zshaddhistory() {
  emulate -L zsh
  setopt extendedglob
  [[ $1 != ${~HISTORY_IGNORE} ]]
}
