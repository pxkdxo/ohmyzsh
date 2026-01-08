# zsh parameters
# see zshparam(1)

typeset -g LISTMAX=0
typeset -g DIRSTACKSIZE=10
typeset -g CORRECT_IGNORE='_*'
typeset -g CORRECT_IGNORE_FILE='*~'
typeset -g HISTSIZE=50000
typeset -g SAVEHIST=10000
typeset -g NULLCMD=':'
typeset -g READNULLCMD="${PAGER:-less}"
typeset -g PROMPT_EOL_MARK=''
typeset -g -H SPROMPT='%N: %1F%U%R%u%f: perhaps you meant %2F%U%r%u%f [%By%b/%Bn%b/%Be%b/%Ba%b]: '

function history_ignore_commands() {
  local ifs=$' \t\n'
  local ignore_re="^[${ifs}]*(${(j.|.)@})([${ifs}].*[^${ifs}])?[${ifs}]*$"
  emulate -R zsh -c '
  zshaddhistory() {
    setopt rematchpcre
    ! [[ $1 =~ '"'${ignore_re//'/'\\''}'"' ]]
  }'
}

history_ignore_commands '[bf]g' 'fc' 'history' 'clear' 'ecryptfs-u?mount-private' '.*/\.\.\.(/[[:graph:]]*)?'
