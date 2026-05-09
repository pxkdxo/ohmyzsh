# venv.plugin.zsh
#
# Detect Python virtual environments along the path of the current working
# directory and offer to activate them. Automatically deactivate the
# environment when leaving its directory tree.


# https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"


# Path of the venv this plugin activated. We only auto-deactivate environments
# we activated ourselves, never one the user activated manually.
typeset -g _VENV_PLUGIN_MANAGED=""

# Path of the most recently declined venv, so we don't re-prompt while the
# user remains within its tree.
typeset -g _VENV_PLUGIN_DECLINED=""

# When non-empty, the plugin's chpwd / precmd machinery is dormant. Toggled
# via the `autovenv` command or by pressing 'd' at the activation prompt.
typeset -g _VENV_PLUGIN_DISABLED=""


# Print the shell-quoted, $HOME-abbreviated form of $1 to stdout.
#
# Avoids ${(qD)...}: the (D) flag matches any named parameter whose value
# equals the path (including globals like REPLY), producing spurious output
# like `~REPLY`. Manual $HOME substitution is immune to that scope leakage.
function __venv_abbrev() {
  emulate -LR zsh
  local __p="${1}"
  if [[ "${__p}" == "${HOME}" ]]; then
    print -r -- '~'
  elif [[ "${__p}" == "${HOME}/"* ]]; then
    print -r -- "~/${(q)__p#"${HOME}/"}"
  else
    print -r -- "${(q)__p}"
  fi
}


# Find the nearest ancestor of $1 (or $PWD) that has a venv directory as a
# child. On success, sets REPLY to the absolute path of the venv root.
function __venv_find_nearest() {
  emulate -LR zsh
  setopt extendedglob noglobsubst
  typeset -g REPLY=""
  local start="${1:-$PWD}"
  [[ -d "${start}" ]] || return 1
  # (../)#       : zero or more parent hops. With Y1 we stop at the first
  #                discovered match, and zsh expands `(../)#` in shallowest-
  #                first order, so we get the *nearest* venv. Without Y1,
  #                glob results would be alphabetically sorted and a more
  #                distant ancestor's venv could win.
  # (|.)(v|virtual)env : matches venv, virtualenv, .venv, .virtualenv. We
  #                deliberately do NOT match bare `env`/`.env`; `.env` is
  #                overwhelmingly used as a dotenv file.
  # (.NY1:A:h:h) : regular file, nullglob, first match, absolute, strip
  #                /bin and /activate to leave the venv root.
  local -a match
  match=( "${start}"/(../)#(|.)(v|virtual)env/bin/activate(.NY1:A:h:h) )
  (( ${#match} )) || return 1
  REPLY="${match[1]}"
}


function __venv_define_activate() {
  # Skip the redefine if `activate` already sources exactly this path. Saves
  # churn on every chpwd within a venv tree.
  if [[ "${functions[activate]-}" == *"source -- ${(q)1}/bin/activate"* ]]; then
    return 0
  fi
  local _abbrev="$(__venv_abbrev "$1")"
  local _quoted="${(q)1}"
  emulate -R zsh -c '
    function activate() {
      print -- "source -- '"${_abbrev}"'/bin/activate"
      source -- '"${_quoted}"'/bin/activate
    }
  '
}


function __venv_do_activate() {
  __venv_define_activate "$1"
  activate || return
  unset -f activate
  _VENV_PLUGIN_MANAGED="$1"
  _VENV_PLUGIN_DECLINED=""
}


function __venv_do_deactivate() {
  if typeset -f deactivate >/dev/null; then
    deactivate
  fi
  if typeset -f activate >/dev/null; then
    unset -f activate
  fi
  _VENV_PLUGIN_MANAGED=""
}


# Prompt to activate; Enter defaults to Yes. Returns 0 on yes, 1 on no or
# disable. Pressing 'd' sets _VENV_PLUGIN_DISABLED and prints its own
# explanation; the caller can check the flag if it wants to suppress
# follow-up output.
function __venv_prompt() {
  local REPLY=""
  print -- "Found a python environment at $(__venv_abbrev "$1")"
  while print -n -- "Activate? [Y/n/d] " && read -k 1 -r REPLY; do
    case "${REPLY}" in
      ($'\n'|$'\r')
        return 0 ;;
      ([Yy])
        echo
        return 0 ;;
      ([Nn])
        echo
        return 1 ;;
      ([Dd])
        echo
        _VENV_PLUGIN_DISABLED=1
        print -- "autovenv: disabled (run 'autovenv enable' to resume)"
        return 1 ;;
    esac
    echoti el1
    echoti hpa 0
  done
  echo
  return 1
}


function __venv_hook() {
  emulate -L zsh
  [[ -o interactive ]] || return 0
  [[ -z "${_VENV_PLUGIN_DISABLED}" ]] || return 0

  local REPLY=""
  local nearest=""
  if __venv_find_nearest; then
    nearest="${REPLY}"
  fi

  # Same env as currently active -> nothing to do.
  if [[ -n "${nearest}" && "${nearest}" == "${VIRTUAL_ENV}" ]]; then
    _VENV_PLUGIN_DECLINED=""
    return 0
  fi

  # Left the tree of a venv we activated -> deactivate it. If the user has
  # since activated a different env on top of ours, leave their env alone and
  # just drop our bookkeeping.
  if [[ -n "${_VENV_PLUGIN_MANAGED}" && "${nearest}" != "${_VENV_PLUGIN_MANAGED}" ]]; then
    if [[ "${VIRTUAL_ENV}" == "${_VENV_PLUGIN_MANAGED}" ]]; then
      __venv_do_deactivate
    else
      _VENV_PLUGIN_MANAGED=""
    fi
  fi

  # Nothing nearby -> done.
  if [[ -z "${nearest}" ]]; then
    _VENV_PLUGIN_DECLINED=""
    return 0
  fi

  # User already declined this exact venv earlier; don't keep asking.
  if [[ "${nearest}" == "${_VENV_PLUGIN_DECLINED}" ]]; then
    return 0
  fi

  # Don't prompt over a venv the user activated themselves.
  if [[ -n "${VIRTUAL_ENV}" ]]; then
    __venv_define_activate "${nearest}"
    return 0
  fi

  # Venvs in $HOME are personal baselines; prompting would just add friction.
  if [[ "${nearest:h}" == "${HOME}" ]]; then
    __venv_do_activate "${nearest}"
    return 0
  fi

  if __venv_prompt "${nearest}"; then
    __venv_do_activate "${nearest}"
  elif [[ -n "${_VENV_PLUGIN_DISABLED}" ]]; then
    : # disabled mid-prompt; the prompt already explained.
  else
    __venv_define_activate "${nearest}"
    _VENV_PLUGIN_DECLINED="${nearest}"
    print -- "Run 'activate' to load the environment"
  fi
}


autoload -U add-zsh-hook
add-zsh-hook chpwd __venv_hook

# Run once at startup so a freshly opened shell inside a project picks up its
# venv without needing a cd. The hook removes itself after the first prompt.
function __venv_startup() {
  add-zsh-hook -d precmd __venv_startup
  unset -f __venv_startup
  __venv_hook
}
add-zsh-hook precmd __venv_startup


# Create a new virtual environment.
function venv() {
  emulate -L zsh
  if (( $# > 1 )); then
    print -u2 -- 'venv: error: too many arguments'
    print -u2 -- 'usage: venv [PATH]'
    return 2
  fi
  local target="${1:-.venv}"

  print -- "python3 -m venv -- $(__venv_abbrev "${target}")"
  python3 -m venv -- "${target}" || return

  local abs="${target:A}"
  print -- "Created a python environment at $(__venv_abbrev "${abs}")"
  if __venv_prompt "${abs}"; then
    __venv_do_activate "${abs}"
  else
    __venv_define_activate "${abs}"
    _VENV_PLUGIN_DECLINED="${abs}"
    print -- "Run 'activate' to load the environment"
  fi
}


# Enable, disable, or query the auto-activation hook.
function autovenv() {
  emulate -L zsh
  local cmd="${1:-status}"
  case "${cmd}" in
    (enable|on)
      _VENV_PLUGIN_DISABLED=""
      # Forget any stale decline so the user gets a fresh prompt in the
      # current tree on re-enable.
      _VENV_PLUGIN_DECLINED=""
      print -- "autovenv: enabled"
      __venv_hook
      ;;
    (disable|off)
      _VENV_PLUGIN_DISABLED=1
      _VENV_PLUGIN_DECLINED=""
      print -- "autovenv: disabled"
      ;;
    (status)
      if [[ -n "${_VENV_PLUGIN_DISABLED}" ]]; then
        print -- "autovenv: disabled"
      else
        print -- "autovenv: enabled"
      fi
      ;;
    (*)
      print -u2 -- "autovenv: unknown command: ${cmd}"
      print -u2 -- "usage: autovenv [enable|disable|status]"
      return 2
      ;;
  esac
}
