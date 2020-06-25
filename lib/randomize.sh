#!/bin/bash

randomize() {

  local last next
  declare -i t n

  # 9*time ~ 500wpm
  n=$((_time*9))
  unset 'words[@]'

  if ((_prop & m[random])); then

    for ((i=0; i<n; i++)); do
      next=$((RANDOM%${#wordlist[@]}))
      ((next == last)) && next=$((RANDOM%${#wordlist[@]}))
      words+=("$next")
      last=$next
    done

  elif ((_prop & m[bookmark])); then

    [[ -f $_bookmarkfile ]] && _bookmark=$(< "$_bookmarkfile")

    ((n+=_bookmark))
    eval "words=({$n..$_bookmark})"
  else
    t=$((${#wordlist[@]}-1))
    
    eval "words=({$t..0})"
  fi
}
