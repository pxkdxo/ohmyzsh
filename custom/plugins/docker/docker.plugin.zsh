#!/usr/bin/env zsh

function docker-run-ubuntu
{
  docker run --interactive --tty --privileged --userns=host --pid=host --network=host --volume="${1:-${PWD:-$(pwd)}}:/home" ubuntu bash
}
