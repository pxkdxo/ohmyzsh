# p5kd5o.zsh-theme
# nice multi-line prompt

zmodload zsh/terminfo

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
  local -A pyvenvcfg=()
  if 2> /dev/null pyvenvcfg=(${(@f)"${(@f)$(< "${VIRTUAL_ENV}/pyvenv.cfg")}"/ #= #/$'\n'})
  then
    print -f '%s' -- "${pyvenvcfg[version]}" $'\n'
  else
    print '?.?.?'
  fi
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

typeset -g -A psvar2=()
psvar2[fg_expr]='%(?.%8F.%1F)'
psvar2[sep]=':'

PROMPT="\
${psvar2[fg_expr]}╭─((%f%10F%n%f${psvar2[fg_expr]}@%f%14F%m%f${psvar2[fg_expr]}${psvar2[sep]}%f%13F\$(__shrink_path)%f${psvar2[fg_expr]})%f\${(%%)\$(__virtualenv_prompt_info)}\${(%%)\$(__git_prompt_info)}
${psvar2[fg_expr]}╰%f%(?.%8F%#%f.%1F%%%f %8F%?%f %1F%#%f) "

ZSH_THEME_GIT_PROMPT_PREFIX='
${psvar2[fg_expr]}├─(%f%10Fgit%f${psvar2[fg_expr]}${psvar2[sep]}%f%14F'
ZSH_THEME_GIT_PROMPT_CLEAN='%f${psvar2[fg_expr]}${psvar2[sep]}%f${ZSH_THEME_GIT_PROMPT_CLEAN_ICON}'
ZSH_THEME_GIT_PROMPT_CLEAN_ICON='%12F%f' 
ZSH_THEME_GIT_PROMPT_DIRTY='%f${psvar2[fg_expr]}${psvar2[sep]}%f${ZSH_THEME_GIT_PROMPT_DIRTY_ICON}'
ZSH_THEME_GIT_PROMPT_DIRTY_ICON='%9F%f'
ZSH_THEME_GIT_PROMPT_SUFFIX='${psvar2[fg_expr]})%f'

ZSH_THEME_VIRTUALENV_PREFIX='
${psvar2[fg_expr]}├─(%f%10Fenv%f${psvar2[fg_expr]}${psvar2[sep]}%f%14F'
ZSH_THEME_VIRTUALENV_SUFFIX='%f${psvar2[fg_expr]}${psvar2[sep]}%f%13F$(__shrink_path "${VIRTUAL_ENV:h}")%f${psvar2[fg_expr]}${psvar2[sep]}%f%11F$(__virtualenv_version_info)%f${psvar2[fg_expr]})%f'

# ╒╤═╤╤═╛ -
# ╞╧╡╞╧╛ --
# ╞╡╞╧╛ ---
# │╞╧╛ ----
# ╞╧╛ -----
# ╘╛ P. DeYoreo
#
# vi:et:ft=zsh:sts=2:sw=2:tw=0
