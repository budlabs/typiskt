#!/bin/bash

timer() {
  declare -i m s remaining 

  remaining=$((_t-SECONDS))
  ((lasttime==-1)) && remaining=$((_time))
  m=$(( remaining/60 ))
  s=$(( remaining%60 ))

  op+="${_c[civis]}${_c[sc]}"
  op+="\e[${pos[tY]};${pos[tX]}H$(printf '%02d:%02d' $m $s)"
  op+="${_c[cnorm]}${_c[rc]}"

  lasttime=$SECONDS

}
