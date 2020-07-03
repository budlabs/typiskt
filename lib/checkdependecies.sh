#!/bin/bash

checkdependencies() {
  local msg

  for d in "${__deps[@]}"; do
    command -v "$d" > /dev/null \
      || msg+="could not find command $d"$'\n'
  done

  [[ -n $msg ]] && ERX "$msg"
}
