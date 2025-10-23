# venv.plugin.zsh
#
# Set up a hook that offers to load any venv found on the path to our working directory

# https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"


# Find the nearest ancestor of a directory with a virtual env as a child.
# If called with no arguments, operate on the current working directory.
# Upon success, the result is appended to the ``reply'' array.
function __find_nearest_venv() {
  emulate -LR zsh
  setopt extendedglob globassign noglobsubst
  typeset -g REPLY
  if ! [[ -d ${1-.} ]]; then
    return 1
  fi
  REPLY=${1-.}/(../)#(|.)(|v|virtual)env/bin/activate(.NY1:A:h:h)
  if ! [[ -n "${REPLY}" ]]; then
    return 1
  fi
}


# check if we've encountered a new nearest venv
function __venv_hook() {
  emulate -L zsh
  set -o verbose
  local venv=""
  local REPLY=""

  if ! __find_nearest_venv; then
    if typeset -f activate > /dev/null; then
      unset -f activate
    fi
    return 0
  fi
  venv="${REPLY}"
  if [[ "${venv}" == "${VIRTUAL_ENV}"  ]]; then
    return 0
  fi
  if [[ "${PWD}" != "${OLDPWD}" ]] && __find_nearest_venv "${OLDPWD}" && [[ "${REPLY}" == "${venv}" ]]; then
    return 0
  fi
  if typeset -f activate > /dev/null; then
    unset -f activate
  fi
  print 'Found a python env at' "${(q)venv}"

  emulate -R zsh -c 'function activate() {
    print "source -- "'"${(q)venv}"'"/bin/activate"
    source -- '"${(q)venv}"'/bin/activate
  }'
  if ! [[ -v VIRTUAL_ENV ]]; then
    while print -n 'Activate? [Y/n] ' && read -k 1 -r REPLY; do
      case "${(U)REPLY}" in
        (Y)
          echo
          activate
          return ;;
        (N)
          break ;;
      esac
      echoti el1
      echoti hpa 0
    done
    echo
  fi
  print "Run 'activate' to load the virtual environment"
}

# Add venv hook
autoload -U add-zsh-hook
add-zsh-hook chpwd __venv_hook


# create a new virtual environment
function venv() {
	emulate -L zsh
  if test "$#" -gt 1; then
    print 'venv: error: too many arguments' >&2
    print 'usage: venv [PATH]' >&2
    return 2
  fi
  local REPLY
  local venv="${1-.venv}"

  print "python3 -m venv -- ${(q)venv}"
  python3 -m venv -- "${venv}"

  print "Created a python environment at ${(q)venv}"
  emulate -R zsh -c 'function activate() {
    print "source -- "'"${(q)venv}"'"/bin/activate"
    source -- '"${(q)venv}"'/bin/activate
  }'
  while print -n 'Activate? [Y/n] ' && read -k 1 -r REPLY; do
    case "${(U)REPLY}" in
      (Y)
        echo
        activate
        return ;;
      (N)
        echo
        print "Run 'activate' to load the virtual environment"
        return ;;
    esac
    echoti el1
    echoti hpa 0
  done
  echo
}
