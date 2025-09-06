# venv.plugin.zsh
#
# Set up a hook that offers to load any venv found on the path to our working directory

# https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# Find the nearest ancestor of a directory with a virtual env as a child.
# If called with no arguments, operate on the current working directory.
# Upon success, the result is appended to the ``reply'' array.
function __find_nearest_venv_root() {
  emulate -LR zsh
  setopt extendedglob globassign noglobsubst
  local RESULT
  typeset -A -g result
  if ! [[ -d ${1-.} ]]; then
    return 1
  fi
  RESULT=${1-.}/(../)#(|.)(|v|virtual)env/bin/activate(.NY1:A)
  if ! [[ -n "${RESULT}" ]]; then
    return 1
  fi
  result[${1-.}]="${RESULT}"
}


# check if we've encountered a new nearest venv
function __venv_hook() {
  emulate -L zsh
  setopt extendedglob noglobsubst noksharrays unset
  set -o verbose
  local -A result=()
  if __find_nearest_venv_root; then
    if [[ -v VIRTUAL_ENV ]] && [[ "${VIRTUAL_ENV}" == "${result[.]}" ]]; then
      return 0
    fi
    if [[ "${PWD}" != "${OLDPWD}" ]] && __find_nearest_venv_root "${OLDPWD}"; then
      if [[ "${result[${OLDPWD}]}" == "${result[.]}" ]]; then
        return 0
      fi
    fi
    if typeset -f activate > /dev/null; then
      unset -f activate
    fi
  else
    if typeset -f activate > /dev/null; then
      unset -f activate
    fi
    return 0
  fi
  print 'Found virtual environment in' "${(q)result[.]:h:h}"
  __venv_found "${result[.]}"
}


# notify user and prompt for activation
function __venv_found() {
  emulate -L zsh
  setopt extendedglob noglobsubst noksharrays unset
  set -o verbose
  local REPLY
  trap '__venv_return '"${(q)1}"' "$?"' EXIT
  if [[ -v VIRTUAL_ENV ]]; then
    return 3
  fi
  while print -n 'Activate? [Y/n] ' && read -k 1 -r REPLY; do
    case "${(U)REPLY}" in
      (Y) return 0 ;;
      (N) return 1 ;;
    esac
    echoti el1
    echoti hpa 0
  done
  return 2
}


# return to the interactive user
function __venv_return() {
  emulate zsh
  set -o verbose
  eval '
  function activate() {
    unset -f activate
    emulate -LR zsh
    print source -- '"${(q)1}"'
    source -- '"${(q)1}"'
  }'
  if test "$2" -lt 3; then
    print
    PROMPT_EOL_MARK='\n'
  fi
  if test "$2" -gt 0; then
    print "Run ''activate'' to load the virtual environment"
  else
    activate
  fi
}


autoload -U add-zsh-hook
add-zsh-hook chpwd __venv_hook


venv () {
	emulate -L zsh
	set -x
	python3 -m venv "${1-./.venv/}"
}
