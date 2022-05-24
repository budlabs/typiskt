#!/bin/bash

setline() {
  # copies nextline to activeline
  # call makeline to create new nextline
  # clear both old lines and print the two new ones

  local k

  unset 'activeline[@]'
  for k in "${!nextline[@]}"; do
    activeline[$k]=${nextline[$k]}
    _lastpos=$k
  done

  _nextpos=0
  makeline

  op+="\e[${pos[aY]};0H$blank\n${blank}\e[${pos[aY]};0H"
  op+="$_activeindent${activeline[*]}\n"
  op+="$_activeindent${nextline[*]}"

}

makeline() {

  # creates new nextline array
  # add words to array, as long as they fit in _maxW

  declare -i ll wl j
  local w

  unset 'nextline[@]'

  while ((${#words[@]})); do
    wln=${words[-1]}
    w=${wordlist[${words[-1]}]}

    ((_difficulty)) && {

      j=$((RANDOM%_difficulty ))
      if [[ -n ${wordmasks[$j]} ]]; then
        w=${wordmasks[$j]/W/$w}
      elif ((j == (${#wordmasks[@]}+1) )); then
        w="$((RANDOM%1111111))"
      elif ((j == (${#wordmasks[@]}+2) )); then
        w=budlabs
      elif ((j == (${#wordmasks[@]}+3) )); then
        w="${w^}"
      elif ((j == (${#wordmasks[@]}+4) )); then
        w="${w^^}"
      fi

    }

    [[ $w = "@@EOL" ]] && {
      unset 'words[-1]'
      unset "wordlist[$wln]"
      break
    }

    wl=${#w}

    (( (ll+=(wl+1)) < _maxW || _prop & m[linebreak])) || break

    # index in array is also xposition
    nextline+=([$((ll-(wl+1)))]="$w")

    unset 'words[-1]'

  done

}
