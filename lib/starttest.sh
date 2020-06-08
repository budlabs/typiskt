#!/bin/bash

starttest() {

  declare -i start=0 lasttime=-1
  clicks=0 badclicks=0 

  pos[pY]=$(( (height/2) - 3))
  pos[aY]=$(( pos[pY]+3 ))
  pos[aX]=$(( (width/2) - (_maxW/2) ))
  pos[tY]=$(( pos[aY]+3 ))
  pos[tX]=$(( (width/2) - (5/2) ))

  # prompt floor
  local f fx fy fw=14
  f=$(printf "%${fw}s" " ")
  f=${f// /─}
  fx=$(( (width/2) - (fw/2) ))
  fy=$((pos[pY]+1))
  pos[pX]=$((fx+1))

  echo -en "\e[${fy};${fx}H$f"
  
  makelist
  randomize 1111
  makeline
  setline
  prompt=""

  nextword
  timer
  while : ; do

    ((start)) && ((SECONDS>_t)) && break
    ((start)) && ((SECONDS != lasttime)) && timer
    
    # https://stackoverflow.com/a/46481173
    IFS= read -rsn1 -t 0.007 key || continue

    if [[ $key = $'\u1b' ]]; then
      read -rsn2 -t 0.001 && continue 
      # echo -en "\e[0;0Hjajajaj"
      return
    # https://askubuntu.com/a/299469
    elif [[ $key = $'\177' ]]; then
      ((${#string}<1)) && continue
      prompt+=$'\b \b'
      string=${string:0:-1}
    elif [[ $key =~ [[:graph:]] ]]; then
      prompt+=$key
      string+=$key
    elif [[ $key = " " ]]; then
      ((clicks++))
      ((oldstatus != 2)) && {
        setstatus 1
        bads=$((${#string} - activelegnth))
        ((badclicks+=(bads<0 ? bads*-1 : bads) ))
      }
      nextword
      continue
    else
      continue
    fi

    ((start)) || { start=1 ; _t=$((_time+SECONDS)) ;}

    ts="$string"
    # hack to allow special chars in regex
    [[ ${string} =~ [][}{\(^$\\] ]] \
      && ts=$(printf '%q' "$string")

    if [[ $activeword = "$string" ]]; then
      status=2
    elif [[ "$activeword" =~ ^${ts} ]]; then
      status=3
    else # don't match
      status=1
    fi

    [[ $key = $'\177' ]] || {
      ((clicks++))
      ((status == 1)) && ((badclicks++))
    }

    ((status == oldstatus)) || setstatus $status
    echo -en "\e[${pos[pY]};${pos[pX]}H${prompt}"

  done

  restart=0
}
