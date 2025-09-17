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

PS_FG='%(?.%8F.%1F)%B'
PS_FG_OFF='%f%b'
PS_SEP='%B:%b'

PROMPT="\
${PS_FG}╭─(${PS_FG_OFF}%10F%n%f${PS_FG}@${PS_FG_OFF}%14F%m%f${PS_FG}${PS_SEP}${PS_FG_OFF}%13F\$(__shrink_path)%f${PS_FG})${PS_FG_OFF}\${(%%)\$(__virtualenv_prompt_info)}\${(%%)\$(__git_prompt_info)}
${PS_FG}╰${PS_FG_OFF}%B%(?.%8F%#%f.%1F%%%f %8F%?%f %1F%#%f)%b "

ZSH_THEME_GIT_PROMPT_PREFIX="
${PS_FG}├─(${PS_FG_OFF}%10Fgit%f${PS_FG}${PS_SEP}${PS_FG_OFF}%14F"
ZSH_THEME_GIT_PROMPT_CLEAN_ICON="%12F%f" 
ZSH_THEME_GIT_PROMPT_DIRTY_ICON="%9F%f"
ZSH_THEME_GIT_PROMPT_SUFFIX="${PS_FG})${PS_FG_OFF}"
ZSH_THEME_GIT_PROMPT_DIRTY="%f${PS_FG}${PS_SEP}${PS_FG_OFF}${ZSH_THEME_GIT_PROMPT_DIRTY_ICON}"
ZSH_THEME_GIT_PROMPT_CLEAN="%f${PS_FG}${PS_SEP}${PS_FG_OFF}${ZSH_THEME_GIT_PROMPT_CLEAN_ICON}"

ZSH_THEME_VIRTUALENV_PREFIX="
${PS_FG}├─(${PS_FG_OFF}%10Fenv%f${PS_FG}${PS_SEP}${PS_FG_OFF}%14F"
ZSH_THEME_VIRTUALENV_SUFFIX="%f${PS_FG}${PS_SEP}${PS_FG_OFF}%13F\$(__shrink_path "${VIRTUAL_ENV:h}")%f${PS_FG}${PS_SEP}${PS_FG_OFF}%11F\$(__virtualenv_version_info)%f${PS_FG})${PS_FG_OFF}"

# ╒╤═╤╤═╛ -
# ╞╧╡╞╧╛ --
# ╞╡╞╧╛ ---
# │╞╧╛ ----
# ╞╧╛ -----
# ╘╛ P. DeYoreo
#
# vi:et:ft=zsh:sts=2:sw=2:tw=0
