#!/bin/bash

timer() {
  declare -i m s t 
  local op=""

  t=$((_t-SECONDS))
  m=$(( t/60 ))
  s=$(( t%60 ))

  # tput sc
  # tput civis
  op+="${_c[civis]}${_c[sc]}"
  op+="\e[${pos[tY]};${pos[tX]}H$(printf '%02d:%02d' $m $s)"
  op+="${_c[cnorm]}${_c[rc]}"
  echo -en "$op"
  # tput rc
  # tput cnorm

  lasttime=$SECONDS

}
