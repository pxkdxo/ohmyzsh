# dircolors.plugin.zsh: Provide a function to load LS_COLORS

typeset -gxT LS_COLORS="${LS_COLORS:-}" ls_colors ":"

() {
  emulate -R zsh
  typeset -g LS_COLORS
  local name
  local filenames
  if command -v vivid > /dev/null; then
    if [[ -v VIVID_THEME ]]; then
      LS_COLORS="$(vivid generate "${VIVID_THEME}")"
      return
    fi
    name=""
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
    name=""
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
    eval"$(dircolors -b)"
  fi
}
