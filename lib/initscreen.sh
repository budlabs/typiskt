#!/bin/bash

initscreen() {

  read -r _height _width < <(stty size)

  # max width, set with -w or default to width-2
  : "${_maxW:=${__o[width]:-50}}"
  _maxW=$(( (_width-2)<_maxW?_width-2:_maxW ))

  pos[pY]=$(( (_height/2) - 2))
  pos[aY]=$(( pos[pY]+3 ))
  pos[aX]=$(( (_width/2) - (_maxW/2) ))
  pos[tY]=$(( pos[aY]+3 ))
  pos[tX]=$(( (_width/2) - (5/2) ))
  pos[fY]=$(( pos[pY]+1 ))
  pos[fX]=$(( (_width/2) - (_underlinewidth/2) ))
  pos[pX]=$(( pos[fX]+1 ))

  local f
  f=$(printf "%${_underlinewidth}s" " ")  f=${f// /─}
  _underline="\e[${pos[fY]};${pos[fX]}H$f"

  blank=$(printf "%${_width}s" " ")
  
  stty -echo
  tput smcup
  tput civis
  tput clear

  trap cleanup HUP TERM EXIT INT
}
