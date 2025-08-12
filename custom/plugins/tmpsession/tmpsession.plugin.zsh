#!/usr/bin/env zsh
# Provides a shell function to create a simple temporary session

#######################################
# temp_hist - make a temporary directory and temporary history to be removed upon exit
# USAGE:
#   temp-hist [-c]
# OPTIONS:
#   -n, --new    Do not copy existing history
# ASSIGNS:
#   HISTFILE: temporary zsh_history file
#   TMPDIR: temporary directory
#######################################
function temp_hist() {
  emulate -LR zsh

  local func_usage="${(q)FUNCTION_ARGZERO} [-n]"
  local func_descripiton=(
		"Create a temporary history file, copying the existing history by default."
		"Options"
		"  -n		Do not copy the current history into the temporary history file."
		"  -q 	Do not print the temporary filename to stdout"
		"  -r	  Do set zshexit() to remove the file when the shell exits" 
	)
  local OPTIND=1
  local OPTARG=""
  local option=""
  local optchars='hnqr'
  local tempfile=""
  local opt_copy=1
  local opt_print=1
  local opt_remove=1

  while getopts ':n' option; do
    case "${option}" in
      'h')
          >&2 printf '%s - %s\n' -- "${FUNCTION_ARGZERO}"
          >&2 printf 'usage: %s\n' -- "${usage}"
          return 2
        ;;
      '?')
          >&2 printf '%s: -%c: invalid option\n' -- "${FUNCTION_ARGZERO}" "${OPTARG}"
          >&2 printf 'usage: %s\n' -- "${usage}"
          return 1
i        ;;
      'n')
          opt_copy=0
        ;;
      'q')
          opt_print=0
        ;;
      'q')
          opt_remove=0
        ;;
    esac

  if ! tempfile="$(mktemp --tmpdir .zsh_history.XXX)"
  then
    return 1
  fi
  if ! eval 'zshexit() { rm -fr -- '"${(q)tempfile}"'; }'
  then
    rm -fr -- "${tempfile}"
    unset -f zshexit
    return 1
  fi
  if test -f "${HISTFILE}"
  then
    cat -- "${HISTFILE}" >> "${tempfile}"
  typeset -g HISTFILE="${tempfile}"
}
