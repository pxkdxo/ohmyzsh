#!/usr/bin/env zsh
# Provides shell functions to generate tags files

#######################################
# ctags-all - recursively generate tags for a directory tree
# Usage:
#   ctags-all [directory]
# Arguments:
#   directory: the directory to operate on (default ``.'')
# Environment:
#   ctags: array of options to pass to ``ctags''
#######################################
function ctags-all() (
  emulate -R zsh
  dirs -- "${1:-.}"
  while popd -q 2> /dev/null
  do
    ctags -f .tags -R
    dirstack+=(*(/-N:a))
  done
)
