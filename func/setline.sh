#!/bin/bash

setline() {

  local i tmpY x_position line_length word

  for ((i=0;i<_number_of_lines;i++)); do
    [[ ${lines[i+1]} ]] || makeline "$((i+1))"
    lines[i]=${lines[i+1]}
    tmpY=$((pos[aY]+i))
    op+="\e[$tmpY;0H$blank\e[$tmpY;0H$_activeindent${lines[$i]}"
  done

  unset 'lines[-1]'
  unset 'activeline[@]'

  for word in ${lines[0]}; do
    ((line_length+=${#word}+1))
    x_position=$(( line_length-(${#word}+1) ))
    activeline[x_position]=$word
  done

  _lastpos=$x_position
  _nextpos=0
}

makeline() {

  declare -i ll j position=$1
  local w wln

  unset 'lines[$position]'

  while ((${#words[@]})); do
    wln=${words[-1]}
    w=${wordlist[$wln]}

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

    (( (ll+=(${#w}+1)) < _maxW || _prop & m[linebreak])) || break

    lines[$position]+="$w "
    unset 'words[-1]'

  done

  lines[$position]="${lines[$position]% }"
}
