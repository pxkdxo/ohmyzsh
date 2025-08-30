# venv.plugin.zsh

# Find the nearest ancestor of a directory with a virtual env as a child.
# If called with no arguments, operate on the current working directory.
# Upon success, the result is appended to the ``reply'' array.
function __nearest_venv_root ()
{
  emulate -LR zsh
  setopt extendedglob globassign noglobsubst
  typeset -g REPLY
  typeset -ag reply
  [[ -d ${1-.} ]] || return
  REPLY=${1-.}/(../)#(|.)(|v|virtual)env/bin/activate(.NY1:A)
  [[ -n "${REPLY}" ]] || return
  reply+=("${REPLY}")
}

# venv chpwd hook
function __venv_activate ()
{
  emulate -L zsh
  setopt extendedglob noglobsubst noksharrays unset
  local REPLY=""
  local reply=()
  if __nearest_venv_root; then
    if __nearest_venv_root "$OLDPWD"; then
      if [[ ${reply[1]} == ${reply[2]} ]]; then
        return
      fi
    fi
    if command -v activate > /dev/null; then
      unset -f activate
    fi
  else
    if command -v activate > /dev/null; then
      unset -f activate
    fi
    return
  fi
  trap '
  local status="$?"
  if test "$((status))" -le 2; then
    print
    PROMPT_EOL_MARK='\''\n'\''
  fi
  if test "$((status))" -le 0; then
    print source -- '"${(q)reply[1]}"'
    source -- '"${(q)reply[1]}"'
    return 0
  fi
  function activate ()
  {
    unset -f activate
    emulate -LR zsh
    print source -- '"${(q)reply[1]}"'
    source -- '"${(q)reply[1]}"'
  }
  print "Run '\''activate'\'' to load the virtual environment"
  ' EXIT
  print 'Found virtual environment in' "${(q)reply[1]:h:h}"
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


chpwd_functions+=(__venv_activate)
