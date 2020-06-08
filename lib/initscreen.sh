#!/bin/bash

initscreen() {

  read -r _height _width < <(stty size)

  # max width, set with -w or default to width-2
  : "${_maxW:=${__o[width]:-$_width}}"
  _maxW=$(((_width-2)<_maxW?_width-2:_maxW))

  stty -echo
  tput smcup
  tput civis
  tput clear

  trap cleanup HUP TERM EXIT INT
}
