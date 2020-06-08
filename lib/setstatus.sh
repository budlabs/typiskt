#!/bin/bash

setstatus() {
  local style status=$1

  style="${_c[f$status]}${activeword}${_c[res]}"
  tput civis
  echo -en "\e[${pos[aY]};$((activepos+1+pos[aX]))H${style}"
  tput cnorm
  oldstatus=$status
}
