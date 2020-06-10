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

  op="\e[${fy};${fx}H$f"
  
  randomize $((_time*9))
  makeline
  setline
  _prompt=""
  _string=""

  nextword
  timer

  while : ; do

    ((start)) && ((SECONDS>_t)) && break
    [[ -n $op ]] && {
      echo -en "$op"
      op=""
    }
    ((start)) && ((SECONDS != lasttime)) && timer
    
    # https://stackoverflow.com/a/46481173
    IFS= read -rsn1 -t 0.01 key || continue

    # pressing escape will restart the game
    if [[ $key = $'\u1b' ]]; then
      read -rsn2 -t 0.001 && continue 
      # read above, to catch arrowkeys etc
      return

    # https://askubuntu.com/a/299469
    # backspace key
    elif [[ $key = $'\177' ]]; then
      ((${#_string}<1)) && continue
      _prompt+=$'\b \b'
      _string=${_string:0:-1}

      ts="$_string"

      # hack to allow special chars in regex
      [[ ${_string} =~ [][}{\(^$\\] ]] \
        && ts=$(printf '%q' "$_string")
      [[ "$_activeword" =~ ^${ts} ]] && status=3 || status=1

      # don't erase a good character
      ((status == 1)) || ((_badclicks++))
      

    # any graphical character
    elif [[ $key =~ [[:graph:]] ]]; then
      _prompt+=$key
      _string+=$key

      ((start)) || { start=1 ; _t=$((_time+SECONDS)) ;}
      nextchar=${_activeword:$((${#_string}-1)):1}

      [[ $key = "$nextchar" ]] && status=3 || status=1

      ((_clicks++))
      ((status == 1)) && ((_badclicks++))

    # space submit word
    elif [[ $key = " " ]]; then
      ((_clicks++))
      ((_oldstatus != 2)) && {
        ((_badclicks++)) 
        ((_activepos == _lastpos)) || setstatus 1
        sl=${#_string}
        cl=$((sl>_activelength?sl:_activelength))
        for ((i=0;i<cl;i++)); do
          c1=${_string:$i:1} c2=${_activeword:$i:1}
          [[ $c1 = "$c2" ]] || ((_badclicks++))
        done
      }
      nextword
      continue
    else
      continue
    fi

    [[ $_activeword = "$_string" ]] && status=2

    ((start)) || { start=1 ; _t=$((_time+SECONDS)) ;}
    ((status == _oldstatus)) || setstatus $status
    op+="\e[${pos[pY]};${pos[pX]}H${_prompt}"

  done

  _restart=0
}
