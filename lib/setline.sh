#!/bin/bash

setline() {
  # copies nextline to activeline
  # call makeline to create new nextline
  # clear both old lines and print the two new ones

  local k

  ((pos[aX])) && indent="$(printf "%${pos[aX]}s" " ")"

  unset 'activeline[@]'

  for k in "${!nextline[@]}"; do
    activeline[$k]=${nextline[$k]}
    _lastpos=$k
  done

  _nextpos=0

  if [[ -n ${__o[exercise]} && ${#words[@]} -eq 0 ]]; then
    unset 'nextline[@]'
  else
    makeline
  fi

  op+="\e[${pos[aY]};0H$blank\n${blank}\e[${pos[aY]};0H"
  op+="$indent${activeline[*]}\n"
  op+="$indent${nextline[*]}"

}

makeline() {

  # creates new nextline array
  # add words to array, as long as they fit in _maxW

  declare -i ll wl j
  local w

  unset 'nextline[@]'

  while :; do
    w=${wordlist[${words[-1]}]}

    ((_difficulty)) && {

      j=$((RANDOM%_difficulty ))
      if [[ -n ${specials[$j]} ]]; then
        w=${specials[$j]/W/$w}
      elif ((j == (${#specials[@]}+1) )); then
        w="$((RANDOM%1111111))"
      elif ((j == (${#specials[@]}+2) )); then
        w=budlabs
      elif ((j == (${#specials[@]}+3) )); then
        w="${w^}"
      elif ((j == (${#specials[@]}+4) )); then
        w="${w^^}"
      fi

    }
   
    wl=${#w}

    (( (ll+=(wl+1)) > _maxW )) && [[ -z ${__o[source]} ]] && break
    [[ $w = "@@EOL" ]] && {
      unset 'words[-1]'
      break
    }

    # index in array is also xposition
    nextline+=([$((ll-(wl+1)))]="$w")
    unset 'words[-1]'

    [[ -n ${__o[exercise]} && ${#words[@]} -eq 0 ]] \
      && break
  done

}
