#!/bin/bash

randomize() {

  local n last next

  n=${1:-100}
  unset 'words[@]'
  

  if [[ -n ${__o[book]} ]]; then
    # notify-send "$(sort -r < "$_list")"
    [[ -f $_bookmarkfile ]] \
      && _bookmark=$(< "$_bookmarkfile")

    ((n+=_bookmark))
    
    eval "words=({$n..$_bookmark})"
  elif [[ -n ${__o[source]} ]]; then
    eval "words=({${#wordlist[@]}..0})"
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
