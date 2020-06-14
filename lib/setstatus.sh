#!/bin/bash

setstatus() {

  # changes color of "_activeword"
  # 1=red, 2=green, 3=yellow

  local style status=$1

  op+="${_c[civis]}${_c[sc]}"
  style="${_c[f$status]}${_activeword}${_c[res]}"
  op+="\e[${pos[aY]};$((_activepos+1+pos[aX]))H${style}"
  # op+="\e[${pos[pY]};$((pos[pX]+${#_string}))H"
  op+="${_c[cnorm]}${_c[rc]}"

  _oldstatus=$status
}
