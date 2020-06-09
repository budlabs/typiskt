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
  
  randomize $((_time*9))
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
        ((_badclicks++)) 
        setstatus 1
        sl=${#_string}
        cl=$((sl>$_activelength?sl:_activelength))
        for ((i=0;i<cl;i++)); do
          c1=${_string:$i:1} c2=${_activeword:$i:1}
          [[ $c1 = c2 ]] || ((_badclicks++))
        done
        # bads=$((${#_string} - _activelength))
        # ((_badclicks+=(bads<0 ? bads*-1 : bads) ))
      }
      nextword
      continue
    else
      continue
    fi

    ((start)) || { start=1 ; _t=$((_time+SECONDS)) ;}

    nextchar=${_activeword:$((${#_string}-1)):1}

    if [[ $_activeword = "$_string" ]]; then
      status=2
    elif [[ $key = "$nextchar" ]]; then
      status=3
    elif [[ $key = $'\177' ]]; then
      ts="$_string"
      # don't erase a good character
      ((status == 1)) || ((_badclicks++))
      # hack to allow special chars in regex
      [[ ${_string} =~ [][}{\(^$\\] ]] \
        && ts=$(printf '%q' "$_string")
      [[ "$_activeword" =~ ^${ts} ]] && status=3 || status=1
    else # don't match
      status=1
    fi

    [[ $key = $'\177' ]] || {
      ((_clicks++))
      ((status == 1)) && ((_badclicks++))
    }

    ((status == _oldstatus)) || setstatus $status
    echo -en "\e[${pos[pY]};${pos[pX]}H${_prompt}"

  done

  _restart=0
}
