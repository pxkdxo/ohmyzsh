(( ! $+commands[asdf] )) && return

export ASDF_DATA_DIR="${ASDF_DATA_DIR:-$HOME/.asdf}"
path=("$ASDF_DATA_DIR/shims" $path)

# If the completion file doesn't exist yet, we need to autoload it and
# bind it to `asdf`. Otherwise, compinit will have already done that.
if [[ ! -f "$ZSH_CACHE_DIR/completions/_asdf" ]]; then
  typeset -g -A _comps
  autoload -Uz _asdf
  _comps[asdf]=_asdf
fi
zmodload -F zsh/files b:zf_mv
() {
  local TMPPREFIX="$ZSH_CACHE_DIR/completions/._asdf"
  zf_mv -f -- =( asdf completion zsh ) "$ZSH_CACHE_DIR/completions/_asdf"
} &|
