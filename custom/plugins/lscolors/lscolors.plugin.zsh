# lscolors.plugin.zsh: keep LS_COLORS in sync with $VIVID_THEME, regenerating
# it (on the next prompt) whenever the theme changes. `vivid generate` output
# is memoised per theme, so flipping back and forth never re-runs vivid. Falls
# back to a vivid theme file or dircolors when VIVID_THEME is unset.

typeset -gxT LS_COLORS="${LS_COLORS:-}" ls_colors ":"
typeset -gA _lscolors_cache       # VIVID_THEME -> generated LS_COLORS

# Fallback when VIVID_THEME is unset: a vivid theme file, else dircolors.
_lscolors_fallback() {
  emulate -L zsh
  typeset -g LS_COLORS
  local name
  local -a filenames
  if command -v vivid > /dev/null; then
    filenames=(
      "${XDG_CONFIG_HOME:-${HOME}/.config}/vivid/themes/default.yaml"
      "${XDG_CONFIG_HOME:-${HOME}/.config}/vivid/theme.yaml"
      "${XDG_CONFIG_HOME:-${HOME}/.config}/vivid.yaml"
    )
    for name in "${filenames[@]}"; do
      if [[ -f "${name}" ]]; then
        LS_COLORS="$(vivid generate "${name}")"
        return
      fi
    done
  fi
  if command -v dircolors > /dev/null; then
    filenames=(
      "${XDG_CONFIG_HOME:-${HOME}/.config}/dircolors"
      "${XDG_CONFIG_HOME:-${HOME}/.config}/DIRCOLORS"
      "${HOME}/.dircolors"
      "${HOME}/.DIRCOLORS"
    )
    for name in "${filenames[@]}"; do
      if [[ -f "${name}" ]]; then
        eval "$(dircolors -b "${name}")"
        return
      fi
    done
    eval "$(dircolors -b)"
  fi
}

# Regenerate LS_COLORS only when VIVID_THEME has changed since the last call
# ($'\0' stands in for "unset", which no real theme name can be).
_lscolors_apply() {
  emulate -L zsh
  typeset -g LS_COLORS
  local cur="${VIVID_THEME-$'\0'}"
  [[ -v _lscolors_last && $cur == $_lscolors_last ]] && return
  _lscolors_last=$cur
  if [[ -v VIVID_THEME ]] && command -v vivid > /dev/null; then
    # `:=` reuses the cached value and skips the subshell on a hit.
    LS_COLORS="${_lscolors_cache[$VIVID_THEME]:=$(vivid generate "${VIVID_THEME}")}"
  else
    _lscolors_fallback
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _lscolors_apply
_lscolors_apply   # apply now so LS_COLORS is set before the first prompt
