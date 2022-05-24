#!/bin/bash

checkdependencies() {
  local msg
  declare -a __deps
  __deps=( bash  bc  gawk  paste  wc  getopt )

  for d in "${__deps[@]}"; do
    command -v "$d" > /dev/null \
      || msg+="could not find command $d"$'\n'
  done

  [[ -n $msg ]] && ERX "$msg"
}
