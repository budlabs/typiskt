#!/bin/bash

setstatus() {

  # changes color of "_activeword"
  # 1=red, 2=green, 3=yellow

  local style status=$1

  style="${_c[f$status]}${_activeword}${_c[res]}"
  op+="\e[${pos[aY]};$((_activepos+1+pos[aX]))H${style}"
  op+="\e[${pos[pY]};$((pos[pX]+${#_string}))H"

  _oldstatus=$status
}
