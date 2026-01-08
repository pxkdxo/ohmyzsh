#!/usr/bin/env zsh
# mkcd.plugin.zsh: shortcuts to common command pairs

# Standarized way of handling finding plugin dir,
# regardless of functionargzero and posixargzero,
# and with an option for a plugin manager to alter
# the plugin directory (i.e. set ZERO parameter)
# https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"


#######################################
# cdls - Enter a directory and list its contents
# Usage:
#   cdls [LS_OPTIONS] DIRECTORY
# ARGUMENTS:
#   LS_OPTIONS: options for 'ls'
#   DIRECTORY: target directory
#######################################
function cdls() {
  if (( "$#" < 1 )); then
    echo "cdls: too few arguments" >&2
    return 2
  fi
  cd -- "${(P)#}" && ls "${@:1:-1}"
}


#######################################
# mkcd - create a directory and enter it
# Usage:
#   mkcd DIRECTORY
# Arguments:
#   DIRECTORY: target directory
#######################################
function mkcd() {
  if (( "$#" < 1 )); then
    echo "mkcd: too few arguments" >&2
    return 2
  fi
  mkdir -p "$@" && cd -- "${(P)#}"
}


#######################################
# mkcp - create a directory and move files into it
# Usage:
#   mkmv [MV_OPTIONS] SOURCE ... DIRECTORY
# Arguments:
#   SOURCE ...: paths to move
#   DIRECTORY: destination
#######################################
function mkmv() {
  if (( "$#" < 1 )); then
    echo "mkmv: too few arguments" >&2
    return 2
  fi
  mkdir -p -- "${(P)#}" && mv "$@"
}


#######################################
# mkcp - create a directory and copy files into it
# Usage:
#   mkcp [CP_OPTIONS] SOURCE ... DIRECTORY
# Arguments:
#   SOURCE ...: paths to copy
#   DIRECTORY: destination
#######################################
function mkcp() {
  if (( "$#" < 1 )); then
    echo "mkcp: too few arguments" >&2
    return 2
  fi
  mkdir -p -- "${(P)#}" && cp "$@"
}
