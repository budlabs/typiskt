#!/bin/bash

randomize() {

  local n last next
  declare -i t
  n=${1:-100}
  unset 'words[@]'
  

  if [[ -n ${__o[book]} ]]; then

    [[ -f $_bookmarkfile ]] && _bookmark=$(< "$_bookmarkfile")

    ((n+=_bookmark))
    eval "words=({$n..$_bookmark})"

  elif [[ -n ${__o[source]} || -n ${__o[exercise]} ]]; then
    t=${#wordlist[@]}
    eval "words=({$t..0})"
  else
    declare -a nums
    
    nums=("${!wordlist[@]}")
    for ((i=0; i<n; i++)); do
      next=$((RANDOM%${#nums[@]}))
      ((next == last)) && next=$((RANDOM%${#nums[@]}))
      words+=("${nums[$next]}")
      last=$next
    done
  fi
}
