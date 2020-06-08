#!/bin/bash

setstatus() {

  # changes color of "activeword"
  # 1=red, 2=green, 3=yellow

  local style status=$1

  style="${_c[f$status]}${_activeword}${_c[res]}"
  tput civis
  echo -en "\e[${pos[aY]};$((_activepos+1+pos[aX]))H${style}"
  tput cnorm

  _oldstatus=$status
}
