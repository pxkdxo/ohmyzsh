# p5kd5o.zsh-theme
# nice multi-line prompt

zmodload zsh/terminfo

autoload -U add-zsh-hook

if functions shrink_path > /dev/null; then
  function __shrink_path() {
    local retval="$?"
    emulate -LR zsh
    shrink_path --glob --last --tilde "$@"
    return "${retval}"
  }
else
  function __shrink_path() {
    local retval="$?"
    emulate -LR zsh
    local components=("${(@)${(@s:/:)${(D)^${1:-.}:P}}//\%/%%}")
    components[1,-2]=("${(%)${(@A):-"%2>*>${(@A)^components[1,-2]}"}[@]}")
    print -f %s\\n -- "${(j:/:)components[@]}"
    return "${retval}"
  }
fi

function __git_prompt_info() {
  local retval="$?"
  emulate -LR zsh
  setopt promptsubst
  2> /dev/null git_prompt_info
  return "${retval}"
}

function __virtualenv_prompt_info() {
  local retval="$?"
  emulate -LR zsh
  setopt promptsubst
  2> /dev/null virtualenv_prompt_info
  return "${retval}"
}

function __virtualenv_version_info() {
  local retval="$?"
  emulate -LR zsh
  setopt extendedglob
  local pyvenvcfg_file="${VIRTUAL_ENV:+${VIRTUAL_ENV}/pyvenv.cfg}"
  local pyvenvcfg_lines=("${(@f)$(<"${pyvenvcfg_file:-/dev/null}")}")
  local -A pyvenvcfg=("${(@SM)${(@fs.=.)pyvenvcfg_lines}[@]##[[:graph:]]*[[:graph:]]}")
  printf '%s\n' "${pyvenvcfg[version_info]:-UNKNOWN}"
  return "${retval}"
} 2> /dev/null

function __virtualenv_prompt_fix() {
  emulate -LR zsh
  setopt extendedglob
  if [[ -n ${VIRTUAL_ENV} ]]; then
    typeset -g PROMPT="${PROMPT##[[:blank:]]#[([][[:blank:]]#${VIRTUAL_ENV:t}[[:blank:]]#[])][[:blank:]]#}"
  fi
}

autoload -U add-zsh-hook
add-zsh-hook precmd __virtualenv_prompt_fix

typeset -g -A psvar_indices=()
typeset -g -A psvar_expressions=()

function __psvar_indices_update() {
  emulate -LR zsh
  local key
  local -i index=1
  typeset -g -A psvar_expressions
  typeset -g -A psvar_indices
  for key in "${(k)psvar_expressions[@]}"; do
    psvar_indices[${key}]=$(( index++ ))
  done
}

function __psvar_update() {
  emulate -LR zsh
  local key
  typeset -g -a psvar
  typeset -g -A psvar_expressions
  typeset -g -A psvar_indices
  __psvar_indices_update
  for key in "${(k)psvar_expressions[@]}"; do
    set -- "${(z)psvar_expressions[${key}]}"
    if command -v "$1" > /dev/null; then
      psvar[$(( ${psvar_indices[${key}]} ))]="$(eval "$@")"
    elif [[ "$#" -eq 1 && -v "$1" ]]; then
      psvar[$(( ${psvar_indices[${key}]} ))]="${(P)1}"
    else
      psvar[$(( ${psvar_indices[${key}]} ))]="${(e)${(j: :)@}}"
    fi
  done
}

psvar_expressions[cwd]='__shrink_path'
psvar_expressions[git]='__git_prompt_info'
psvar_expressions[pyenv]='__virtualenv_prompt_info'
psvar_expressions[pyenv_vers]='__virtualenv_version_info'
psvar_expressions[pyenv_path]='${VIRTUAL_ENV:h:t}'
psvar_expressions[dirstack]='[${(j.:.)${(D)dirstack[@]}:t}]'

typeset -g ps_style_words=""
typeset -g ps_style_punct="%B%(?.%8F.%1F)"
typeset -g ps_style_reset="%f%b"

typeset -g ps_sep=':'

typeset -g psline_head=(
  '${ps_style_reset}${ps_style_punct}╭─(${ps_style_reset}${ps_style_words}%10F%n${ps_style_reset}${ps_style_punct}@${ps_style_reset}${ps_style_words}%11F%m${ps_style_reset}${ps_style_punct}${ps_sep}${ps_style_reset}${ps_style_words}%13F%${psvar_indices[cwd]}v${ps_style_reset}${ps_style_punct})${ps_style_reset}'
)

typeset -g psline_tail=(
  '${ps_style_reset}${ps_style_punct}├─(${ps_style_reset}${ps_style_words}%10F%D{%a %I:%M %p}${ps_style_reset}${ps_style_punct})${ps_style_reset}'

  '${ps_style_reset}${ps_style_punct}╰${ps_style_reset}%(?.${ps_style_punct}%#${ps_style_reset}.${ps_style_punct}%%${ps_style_reset} ${ps_style_punct}%?${ps_style_reset} ${ps_style_punct}%#${ps_style_reset}) '
)

typeset -g pslines_dynamic=(
  '%${psvar_indices[pyenv]}v'
  '%${psvar_indices[git]}v'
)

function __ps_update() {
  emulate -LR zsh
  setopt promptsubst
  typeset -g -a psvar
  typeset -g -A psvar_expressions
  typeset -g -A psvar_indices
  __psvar_update
  set -- "${(e)psline_head[@]}" "${(%%)${(e)pslines_dynamic[@]}[@]}" "${(e)psline_tail[@]}"
  typeset -g PROMPT="${(@F)@:#}"
}
add-zsh-hook precmd __ps_update


ZSH_THEME_GIT_PROMPT_DIRTY_ICON='✗'
ZSH_THEME_GIT_PROMPT_CLEAN_ICON='✔' 

ZSH_THEME_GIT_PROMPT_DIRTY='${ps_style_reset}${ps_style_punct}${ps_sep}${ps_style_reset}${ps_style_words}%9F${ZSH_THEME_GIT_PROMPT_DIRTY_ICON}%f${ps_style_reset}'
ZSH_THEME_GIT_PROMPT_CLEAN='${ps_style_reset}${ps_style_punct}${ps_sep}${ps_style_reset}${ps_style_words}%7F${ZSH_THEME_GIT_PROMPT_CLEAN_ICON}%f${ps_style_reset}'

ZSH_THEME_GIT_PROMPT_PREFIX='${ps_style_reset}${ps_style_punct}├─(${ps_style_reset}${ps_style_words}%10Fgit%f${ps_style_reset}${ps_style_punct}${ps_sep}${ps_style_reset}${ps_style_words}%11F'
ZSH_THEME_GIT_PROMPT_SUFFIX='${ps_style_reset}${ps_style_punct})${ps_style_reset}'

ZSH_THEME_VIRTUALENV_PREFIX='${ps_style_reset}${ps_style_punct}├─(${ps_style_reset}${ps_style_words}%10Fenv%f${ps_style_reset}${ps_style_punct}${ps_sep}${ps_style_reset}${ps_style_words}%11F'
ZSH_THEME_VIRTUALENV_SUFFIX='${ps_style_reset}${ps_style_punct}${ps_sep}${ps_style_reset}${ps_style_words}%13F%${psvar_indices[pyenv_path]}v%f${ps_style_reset}${ps_style_punct}${ps_sep}${ps_style_reset}${ps_style_words}%9F%${psvar_indices[pyenv_vers]}v%f${ps_style_reset}${ps_style_punct})${ps_style_reset}'

RPROMPT=""

__ps_update

# ╒╤═╤╤═╛ -
# ╞╧╡╞╧╛ --
# ╞╡╞╧╛ ---
# │╞╧╛ ----
# ╞╧╛ -----
# ╘╛ P. DeYoreo
#
# vi:et:ft=zsh:sts=2:sw=2:tw=0
