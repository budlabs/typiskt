#!/bin/bash

starttest() {

  local key c1 c2
  declare -i start=0 lasttime=-1 status sl cl

  _clicks=0  _badclicks=0 _words=0
  _string=""

  # prompt floor
  local f
  declare -i fx fy
  declare -i fw=14   # floor width

  f=$(printf "%${fw}s" " ")  f=${f// /─}
  fx=$(( (_width/2) - (fw/2) )) fy=$((pos[pY]+1))
  pos[pX]=$((fx+1))

  op="\e[${fy};${fx}H$f"
  
  # 9*time ~ 500wpm
  randomize $((_time*9))
  makeline
  setline
  nextword
  timer

  while : ; do

    ((start && SECONDS>_t)) && break

    # update screen
    [[ -n $op ]] && { echo -en "$op" ; op="" ;}

    ((start && SECONDS != lasttime)) && timer
    
    # https://stackoverflow.com/a/46481173
    IFS= read -rsn1 key || continue

    # any graphical character
    if [[ $key =~ [[:graph:]] ]]; then
      _string+=$key

      # start the timer
      ((start)) || { start=1 ; _t=$((_time+SECONDS)) ;}

      nextchar=${_activeword:$((${#_string}-1)):1}
      [[ $key = "$nextchar" ]] && status=$_oldstatus \
                               || status=1
      
      ((++_clicks && status == 1 && _badclicks++))

    # space, submit word (empty $key == Enter)
    elif [[ $key = " " || -z $key ]]; then
      (( _words++ + _clicks++ ))
      ((_oldstatus != 2 && ++_badclicks)) && {
        
        ((_oldstatus == 1 || _activepos == _lastpos)) \
          || setstatus 1

        sl=${#_string}
        cl=$((sl>_activelength?sl:_activelength))
        for ((i=0;i<cl;i++)); do
          c1=${_string:$i:1} c2=${_activeword:$i:1}
          [[ $c1 = "$c2" ]] || ((_badclicks++))
        done
      }
      nextword
      continue
    # https://askubuntu.com/a/299469
    # backspace key
    elif [[ $key = $'\177' ]]; then
      ((${#_string}<1)) && continue
      key=$'\b \b'
      _string=${_string:0:-1}

      [[ $_string = "${_activeword:0:${#_string}}" ]] \
        && status=3 || status=1

      # penalty for erasing good char
      ((_oldstatus == 1 || _badclicks++)) 
    # pressing escape will restart the game
    elif [[ $key = $'\u1b' ]]; then
      # catch arrowkeys etc
      read -rsn2 -t 0.001 && continue 
      return  
    else
      continue
    fi

    [[ $_activeword = "$_string" ]] && status=2

    ((status == _oldstatus)) || setstatus $status
    op+="$key"

  done

  _restart=0
}
