#!/bin/bash

makeline() {

  declare -i ll wl j
  local w

  unset 'nextline[@]'

  while :; do
    w=${wordlist[${words[-1]}]}

    dfclt=8

    j=$((RANDOM%((${#specials[@]} * (11-dfclt) )+4) ))
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
   

    wl=${#w}
    (( (ll+=(wl+1)) > _maxW )) && break
    nextline+=([$((ll-(wl+1)))]="$w")
    unset 'words[-1]'
    ((${#words}<1)) && randomize 100
  done

}

setline() {
  local k op=""

  ((pos[aX])) && indent="$(printf "%${pos[aX]}s" " ")"

  unset 'activeline[@]'

  for k in "${!nextline[@]}"; do
    activeline[$k]=${nextline[$k]}
    lastpos=$k
  done

  nextpos=0
  makeline

  op="\e[${pos[aY]};0H$blank\n${blank}\e[${pos[aY]};0H"
  op+="$indent${activeline[*]}\n"
  op+="$indent${nextline[*]}"

  # echo -en "\e[${pos[aY]};0H$blank\n$blank"
  echo -en "$op"
}

# active line is always top
# keys can be x pos

# 0123456
# began small old home on began spell country
# [0]=began [6]=small
