# zsh completion styles
# see zshcompsys(1), zshmodules(1)

# Ensure a cache directory for completion data and enable helpful defaults
if ! [[ -d "${ZSH_CACHE_DIR:=${XDG_CACHE_HOME:-${HOME}/.cache}/zsh}" ]]; then
  mkdir -p "${ZSH_CACHE_DIR}/completion"
fi
zstyle ':completion:*' completer _expand _oldlist _complete _correct _approximate _match _ignored
zstyle ':completion:*' cache-path "${ZSH_CACHE_DIR}/completion"
zstyle ':completion:*' complete true
zstyle ':completion:*' completions true
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' file-sort name
zstyle ':completion:*' glob true
zstyle ':completion:*' ignore-parents parent pwd .. directory
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' keep-prefix true
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
zstyle ':completion:*' list-prompt '%S[%U%p%u] -- <%UTab%u> to continue --%s'
zstyle ':completion:*' list-rows-first true
zstyle ':completion:*' match-original both
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]\-}={[:upper:]\_}' 'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{[:lower:]\-}={[:upper:]\_}' 'r:|?=** m:{[:lower:]\-}={[:upper:]\_}'
zstyle ':completion:*' menu select=2
zstyle ':completion:*' old-list match
zstyle ':completion:*' old-menu false
zstyle ':completion:*' original true
zstyle ':completion:*' preserve-prefix '//[^/]##/'
zstyle ':completion:*' rehash true
zstyle ':completion:*' select-prompt '%S[%U%m%u]%s'
zstyle ':completion:*' squeeze-slashes false
zstyle ':completion:*' substitute true
zstyle ':completion:*' suffix false
zstyle ':completion:*' use-cache true
zstyle ':completion:*' verbose true
zstyle ':completion:*' word true

zstyle ':completion:*:correct:*' original true
zstyle ':completion:*:correct:*' prompt '%N: %3F%U%e%u%f: correct to %2F%U%c%u%f [%By%b/%Bn%b] '
zstyle -e ':completion:*:correct:*' max-errors 'reply=("$(( (${#PREFIX} + ${#SUFFIX}) / 4 ))" numeric)'
zstyle -e ':completion:*:approximate:*' max-errors 'reply=("$(( (${#PREFIX} + ${#SUFFIX}) / 4 ))" numeric)'

zstyle ':completion:*:expand:*' tag-order all-expansions

zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' stop yes

zstyle ':completion:*:matches' group yes

zstyle ':completion:*:messages' format '%d'

zstyle ':completion:*:options' description yes
zstyle ':completion:*:options' auto-description '%d'

zstyle ':completion:*:warnings' format '%F{white}--%f %F{red}%Uno matches%u%f %F{white}--%f'

zstyle ':completion:*:sudo:*' environ "path=${path:-$(getconf path)}"

zstyle ':completion:*:cd:*' special-dirs true
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

zstyle ':completion:*:*:zcompile:*' ignored-patterns '*(\~|.zwc)'

zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
zstyle ':completion:*:*:-command-:*:commands' ignored-patterns '*\~'

zstyle ':completion:*:*:*:*:functions' ignored-patterns '(.|_[^_])*'

if [[ "$(uname -o)" == Darwin* ]]; then
  zstyle ':completion:*:*:*:*:processes' command 'ps -Ao pid,user,comm -c'
else
  zstyle ':completion:*:*:*:*:processes' command 'ps cww -afj'
fi
