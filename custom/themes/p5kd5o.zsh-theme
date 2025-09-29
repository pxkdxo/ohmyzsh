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
  setopt promptpercent promptsubst
  2> /dev/null git_prompt_info
  return "${retval}"
}

function __virtualenv_prompt_info() {
  local retval="$?"
  emulate -LR zsh
  setopt promptpercent promptsubst
  2> /dev/null virtualenv_prompt_info
  return "${retval}"
}

function __virtualenv_version_info() {
  local retval="$?"
  emulate -LR zsh
  setopt extendedglob
  local pyenvcfg_file="${VIRTUAL_ENV:+${VIRTUAL_ENV}/pyvenv.cfg}"
  local pyenvcfg_lines=("${(@f)$(<"${pyenvcfg_file:-/dev/null}")}")
  local -A pyenvcfg=("${(@SM)${(@fs.=.)pyenvcfg_lines}[@]##[[:graph:]]*[[:graph:]]}")
  printf '%s\n' "${pyenvcfg[version]:-UNKNOWN}"
  return "${retval}"
}

function __virtualenv_prompt_fix() {
  emulate -LR zsh
  setopt extendedglob
  if [[ -n ${VIRTUAL_ENV} ]]; then
    typeset -g PROMPT="${PROMPT##[[:blank:]]#[([][[:blank:]]#${VIRTUAL_ENV:t}[[:blank:]]#[])][[:blank:]]#}"
  fi
}

autoload -U add-zsh-hook
add-zsh-hook precmd __virtualenv_prompt_fix

typeset -g -A psvar_indices=(
  ['__shrink_path']=$(( ${#psvar[@]} + 1 ))
  ['__git_prompt_info']=$(( ${#psvar[@]} + 2 ))
  ['__virtualenv_prompt_info']=$(( ${#psvar[@]} + 3 ))
  ['__virtualenv_version_info']=$(( ${#psvar[@]} + 4 ))
  ['"${VIRTUAL_ENV:h}"']=$(( ${#psvar[@]} + 5 ))
)

function __psvar_update() {
  emulate -LR zsh
  local ind
  local key
  typeset -g -a psvar
  typeset -g -A psvar_indices
  for key ind in "${(kv)psvar_indices[@]}"; do
    if command -v "${key}" > /dev/null; then
      psvar[ind]="$("${key}")"
    else
      eval "psvar[ind]=${key}"
    fi
  done 2> /dev/null
}

typeset -g ps_fg_on='%B%(?.%8F.%1F)'
typeset -g ps_fg_err='%B%(?.%8F.%1F)'
typeset -g ps_fg_off='%f%b'
typeset -g ps_sep=':'

typeset -g psline_first="${ps_fg_on}╭─(${ps_fg_off}%10F%n%f${ps_fg_on}@${ps_fg_off}%14F%m%f${ps_fg_on}${ps_sep}${ps_fg_off}%13F%${psvar_indices[__shrink_path]}v%f${ps_fg_on})${ps_fg_off}"

typeset -g  psline_last="${ps_fg_on}╰${ps_fg_off}%(?.${ps_fg_on}%#${ps_fg_off}.${ps_fg_err}%%${ps_fg_off} ${ps_fg_on}%?${ps_fg_off} ${ps_fg_err}%#${ps_fg_off}) "

typeset -g -a pslines_dynamic=(
  "%${psvar_indices[__virtualenv_prompt_info]}v"
  "%${psvar_indices[__git_prompt_info]}v"
)

PROMPT=""
RPROMPT=""

function __ps_update() {
  emulate -LR zsh
  setopt promptsubst
  typeset -g -a psvar
  typeset -g -A psvar_indices
  __psvar_update
  set -- "${psline_first}" "${(%%)pslines_dynamic[@]}" "${psline_last}"
  typeset -g PROMPT="${(@F)@:#}"
}
__ps_update

add-zsh-hook precmd __ps_update

ZSH_THEME_VIRTUALENV_PREFIX="${ps_fg_on}├─(${ps_fg_off}%10Fenv%f${ps_fg_on}${ps_sep}${ps_fg_off}%14F"
ZSH_THEME_VIRTUALENV_SUFFIX="%f${ps_fg_on}${ps_sep}${ps_fg_off}%13F%${psvar_indices[VIRTUAL_ENV]}v%f${ps_fg_on}${ps_sep}${ps_fg_off}%11F%${psvar_indices[__virtualenv_version_info]}v%f${ps_fg_on})${ps_fg_off}"

ZSH_THEME_GIT_PROMPT_CLEAN_ICON="%12F%f" 
ZSH_THEME_GIT_PROMPT_DIRTY_ICON="%9F%f"
ZSH_THEME_GIT_PROMPT_DIRTY="%f${ps_fg_on}${ps_sep}${ps_fg_off}${ZSH_THEME_GIT_PROMPT_DIRTY_ICON}"
ZSH_THEME_GIT_PROMPT_CLEAN="%f${ps_fg_on}${ps_sep}${ps_fg_off}${ZSH_THEME_GIT_PROMPT_CLEAN_ICON}"
ZSH_THEME_GIT_PROMPT_PREFIX="${ps_fg_on}├─(${ps_fg_off}%10Fgit%f${ps_fg_on}${ps_sep}${ps_fg_off}%14F"
ZSH_THEME_GIT_PROMPT_SUFFIX="${ps_fg_on})${ps_fg_off}"

# ╒╤═╤╤═╛ -
# ╞╧╡╞╧╛ --
# ╞╡╞╧╛ ---
# │╞╧╛ ----
# ╞╧╛ -----
# ╘╛ P. DeYoreo
#
# vi:et:ft=zsh:sts=2:sw=2:tw=0
