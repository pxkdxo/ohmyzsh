# zsh completion styles
# see zshcompsys(1), zshmodules(1)

# Rehash upon completion so programs are found immediately after installation
function _force_rehash() {
  emulate -LR zsh
  if (( CURRENT == 1 )); then
    rehash
  fi
  return 1
}

#zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' completer _oldlist _force_rehash _expand _complete _match _prefix _approximate _ignored _files
zstyle ':completion:*' completions true
zstyle ':completion:*' complete true
zstyle ':completion:*' condition false
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' file-sort name
zstyle ':completion:*' glob true
zstyle ':completion:*' ignore-parents parent pwd .. directory
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' keep-prefix true
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
zstyle ':completion:*' list-prompt '%S[%U%p%u] -- <%UTab%u> to continue --%s'
zstyle ':completion:*' match-original both
#zstyle ':completion:*' matcher-list '' '+m:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'
zstyle ':completion:*' matcher-list '' '+m:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*' '+b:|=* r:|=*' '+b:|=* l:|=*'
zstyle ':completion:*' menu select=2
zstyle ':completion:*' old-list match
zstyle ':completion:*' old-menu false
zstyle ':completion:*' original true
zstyle ':completion:*' preserve-prefix '//[^/]##/'
#zstyle ':completion:*' rehash true
zstyle ':completion:*' select-prompt '%S[%U%m%u]%s'
zstyle ':completion:*' squeeze-slashes false
zstyle ':completion:*' substitute true
zstyle ':completion:*' suffix false
zstyle ':completion:*' use-cache true
zstyle ':completion:*' verbose true
zstyle ':completion:*' word true
zstyle -e ':completion:*' max-errors 'reply=("$(( (${#PREFIX} + ${#SUFFIX}) / 4 ))" numeric)'

zstyle ':completion:*:correct:*' original true
zstyle ':completion:*:expand:*' tag-order all-expansions
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:matches' group yes
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:options' description yes
zstyle ':completion:*:warnings' format '%F{white}--%f %F{red}%Uno matches%u%f %F{white}--%f'

zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:sudo:*' environ "path=${path:-$(getconf path)}"
#zstyle ':completion:*:sudo:*' environ "PATH=${$(sudo -nu "${USER:-$(id -nu)}" printenv PATH 2>/dev/null):-${PATH:-$(getconf PATH)}}"

# Styles for specific completion contexts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
zstyle ':completion::(^approximate*):*:functions' ignored-patterns '(.|_[^_])*'
zstyle ':completion:*:*:zcompile:*' ignored-patterns '*(\~|.zwc)'
zstyle ':completion:*:*:-command-:*:commands' ignored-patterns '*\~'

zstyle ':completion:*:*:*:*:processes' command 'ps cww -afj'
