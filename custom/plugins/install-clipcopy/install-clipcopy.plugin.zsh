#!/usr/bin/env zsh
#
# Install clipcopy and clippaste as shell scripts. Then we can call them elsewhere.


# usage: _create_script_body_from_function FUNCTION_NAME [INTERPRETER [INTERPRETER_ARG]]
function _create_script_body_from_function() {
  emulate -LR zsh
  if test "$#" -lt 1; then
    return 2
  fi
  local function_name="$1"
  local function_call=("${function_name}" '"$@"')
  local function_body="$(functions -- "${function_name}" 2> /dev/null)"
  local interpreter_directive=(/usr/bin/env zsh)
  shift
  if test "$#" -gt 2; then
    return 2
  fi
  if test "$#" -gt  0; then
    interpreter_directive=("$@")
  fi
  if test -z "${function_body}"; then
    return 1
  fi
  cat << EOF
#!${interpreter_directive[@]}
# Generated on $(date +%+)

${function_body}

${function_call[@]}
EOF
}


# usage: _create_script_files_from_functions DEST_PATH FUNCTION_NAME ...
function _create_script_files_from_functions() {
  if (($# == 0)); then
    return 2
  fi
  local dest_path="$1"
  shift
  if (($# == 0)); then
    return 2
  fi
  local funcname
  for funcname in "$@"; do
    if ! _create_script_body_from_function "${funcname}" >| "${dest_path=}/${funcname}"; then
      return 1
    fi
    shift
  done
}


# usage: _make_functions_into_scripts BIN_DIR FUNCTION_NAME ...
function _make_functions_into_scripts() {
  emulate -LR zsh
  local tmp_dir
  if (("$#" == 0)); then
    return 2
  fi
  local bin_dir="$1"
  shift
  if (("$#" == 0)); then
    return 2
  fi
  local function_names=("$@")
  if ! tmp_dir="$(mktemp -d --tmpdir "${(j:.:)funcstack[@]:t:r}.XXX")"; then
    return 1
  fi
  if ! trap "rm -rf -- ${(q)tmp_dir} < /dev/null > /dev/null 2>&1" EXIT; then
    rm -rf -- "${tmp_dir}"
    return 1
  fi
  if ! _create_script_files_from_functions "${tmp_dir}" "${(@)function_names}"; then
    return "$?"
  fi
  if ! install -m 0755 "${tmp_dir}"/* "${bin_dir}" > /dev/null; then
    return "$?"
  fi
}


# usage: _find_user_bin_path
function _find_user_bin_path() {
  emulate -LR zsh
  setopt extendedglob
  local home_path_directories=()
  local dir_index=0
  local min_index=0
  local dir_parts=0
  local min_parts=0
  printf -v home_path_directories '%s' ${^path[@]}(#qN/-Urwx)
  if (("${#home_path_directories[@]}" == 0)); then
    return 1
  fi
  while ((++dir_index <= "${#home_path_directories[@]}")); do
    dir_parts="${#${(s:/:)home_path_directories[$((dir_index))]#~/}[@]}"
    if ((dir_parts < min_parts || min_parts == 0)); then
      min_index=$((dir_index))
      min_parts=$((dir_parts))
    fi
  done
  typeset -g REPLY
  REPLY="${home_path_directories[$((min_index))]}"
}


# usage: install_clipcopy DESTDIR
function install_clipcopy() {
  emulate -LR zsh
  local bin_dir="${1-${PREFIX:+${PREFIX}/bin}}"
  if ! [[ -n "${bin_dir}" ]]; then
    if ! { _find_user_bin_path && [[ -n "${bin_dir::=${REPLY}}" ]]; }; then
      >&2 "install_clipcopy: cannot find an installation path: set PREFIX and re-run this script"
      return 1
    fi
  fi
  if ! _make_functions_into_scripts "${bin_dir}" clipcopy clippaste; then
    >&2 "install_clipcopy: failed"
    return 1
  fi
}


# Run the installation
install_clipcopy
