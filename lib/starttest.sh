#!/bin/bash

starttest() {

  local key ts
  declare -i start=0 lasttime=-1 status
  _clicks=0 _badclicks=0

  tput clear

  # prompt floor
  local f 
  declare -i fx fy
  declare -i fw=14   # undeline width

  f=$(printf "%${fw}s" " ")  f=${f// /─}
  fx=$(( (_width/2) - (fw/2) )) fy=$((pos[pY]+1))
  pos[pX]=$((fx+1))

  echo -en "\e[${fy};${fx}H$f"
  
  makelist
  randomize 1111
  makeline
  setline
  _prompt=""
  _string=""

  nextword
  timer

  while : ; do

    ((start)) && ((SECONDS>_t)) && break
    ((start)) && ((SECONDS != lasttime)) && timer
    
    # https://stackoverflow.com/a/46481173
    IFS= read -rsn1 -t 0.007 key || continue

    if [[ $key = $'\u1b' ]]; then
      read -rsn2 -t 0.001 && continue 
      # pressing escape will restart the game
      # read above, to catch arrowkeys etc
      return
    # https://askubuntu.com/a/299469
    elif [[ $key = $'\177' ]]; then
      ((${#_string}<1)) && continue
      _prompt+=$'\b \b'
      _string=${_string:0:-1}
    elif [[ $key =~ [[:graph:]] ]]; then
      _prompt+=$key
      _string+=$key
    elif [[ $key = " " ]]; then
      ((_clicks++))
      ((_oldstatus != 2)) && {
        setstatus 1
        bads=$((${#_string} - _activelength))
        ((_badclicks+=(bads<0 ? bads*-1 : bads) ))
      }
      nextword
      continue
    else
      continue
    fi

    ((start)) || { start=1 ; _t=$((_time+SECONDS)) ;}

    ts="$_string"
    # hack to allow special chars in regex
    [[ ${_string} =~ [][}{\(^$\\] ]] \
      && ts=$(printf '%q' "$_string")

    if [[ $_activeword = "$_string" ]]; then
      status=2
    elif [[ "$_activeword" =~ ^${ts} ]]; then
      status=3
    else # don't match
      status=1
    fi

    [[ $key = $'\177' ]] || {
      ((clicks++))
      ((status == 1)) && ((badclicks++))
    }

    ((status == _oldstatus)) || setstatus $status
    echo -en "\e[${pos[pY]};${pos[pX]}H${_prompt}"

  done

  _restart=0
}
