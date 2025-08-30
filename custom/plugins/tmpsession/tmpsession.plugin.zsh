#!/usr/bin/env zsh
# Provides a shell function to create a simple temporary session

#######################################
# tmpsession - make a temporary directory and temporary history to be removed upon exit
# USAGE:
#   tmpsession
# ASSIGNS:
#   HISTFILE: temporary zsh_history file
#   tmpdir: temporary directory
#######################################
function tmpsession()
{                                 
  if ! local tmpdir && tmpdir="$(mktemp -d --tmpdir XXX)"
  then
    return 1
  fi
  if ! eval 'function zshexit() { rm -fr -- '"${(q)tmpdir}"'; }' && cd -- "${tmpdir}"
  then
    rm -fr -- "${tmpdir}"
    unset -f zshexit
    return 1
  fi
  HISTFILE="${tmpdir}/.zsh_history"
}
