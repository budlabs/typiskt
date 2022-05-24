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

    t=$((${#wordlist[@]}-1))
    g=$((t-_bookmark))

    ((g<n)) && while ((${#words[@]}<n)); do
      if ((t<n)); then
        eval "words+=({$t..0})"
      else
        eval "words+=({$n..0})"
      fi
    done

    eval "words+=({$t..$_bookmark})"
    # n=$((t-_bookmark))
    
  else
    t=$((${#wordlist[@]}-1))
    
    eval "words=({$t..0})"
  fi
}
