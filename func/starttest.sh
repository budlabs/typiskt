#!/bin/bash

starttest() {

  local key c1 c2 exd
  declare -i lasttime=-1 status sl cl is_cheating

  _clicks=0  _badclicks=0 _words=0 _start=0 _activepos=-1 _resize=0
  _string=""

  op=$_underline

  [[ -n ${exd:=${_o[exercise]}} ]] && ((pos[pY]>1)) && {

    op+="\e[1;1Hexercise ${exd##*/} "
    op+="($((_lastexercise+1))/${#exercises[@]}) "

    local lwpm # last wpm on current exercise
    [[ -f ${lwpm:=$TYPISKT_CACHE/$_listhash} ]] && {
      lwpm=$( < "$lwpm" )
      lwpm=${lwpm:0:-1}
      op+="best WPM: $lwpm"
      :
    } || op+="               "

    op+="    "
  }
  
  # when linebreaks are used, a new list have to be
  # generated each game
  ((_prop & m[linebreak])) && makelist

  randomize
  makeline
  setline
  nextword
  ((_time)) && timer
  
  until ((_resize)) ; do
    
    ((_start && SECONDS>_t && _time)) && break
    ((_time || ${#wordlist[@]}!=_words)) || break

    # update screen
    [[ -n $op ]] && { echo -en "$op" ; op="" ;}

    ((_start && SECONDS != lasttime && _time)) && timer
    
    # https://stackoverflow.com/a/46481173
    IFS= read -rsn1 key || continue

    [[ $is_cheating ]] && {
      unset -v is_cheating
      op="\e[$_height;0H$blank${_c[rc]}${_c[norm]}"
    }

    # any graphical character
    if [[ $key =~ [[:graph:]] ]]; then
      _string+=$key

      # start the timer
      ((_start)) || { _start=$SECONDS ; _t=$((_time+_start)) ;}

      nextchar=${_activeword:$((${#_string}-1)):1}
      [[ $key = "$nextchar" ]] && status=$_oldstatus \
                               || status=$_statuserror
      
      ((++_clicks && status == _statuserror && _badclicks++))

    # space, submit word (empty $key == Enter)
    elif [[ $key = " " || -z $key ]]; then
      (( _words++ + _clicks++ ))
        
      ((_oldstatus != _statuscorrect && ++_badclicks)) && {
        ((_oldstatus == _statuserror || _activepos == _lastpos)) \
          || setstatus "$_statuserror"

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
    # backspace key or control H
    elif [[ $key = $'\177' || $key = $'\x08' ]]; then
      ((${#_string}<1 && ++_badclicks)) && continue
      key=$'\b \b'
      _string=${_string:0:-1}

      [[ $_string = "${_activeword:0:${#_string}}" ]] \
        && status=$_statusactive || status=$_statuserror

      # penalty for erasing good char
      ((_oldstatus == _statuserror || _badclicks++)) 

    # escape sequence
    elif [[ $key = $'\u1b' ]]; then
      # catch arrowkeys etc
      read -rsn2 -t 0.001 key && {
        # shift exercise
        [[ $_mode = exercise ]] || continue
        case "$key" in
          '[D'|'[A' )  # left/up
            nextex=$((_lastexercise-1<0
                     ?${#exercises[@]}-1:_lastexercise-1))
          ;;
          '[B'|'[C' )  # down/right
            cheating="${_exercisefile%/*}/$_listhash"
            if [[ -f $cheating ]]; then
              nextex=$((_lastexercise+1<${#exercises[@]}
                       ?_lastexercise+1:0))
            else
              op+="${_c[civis]}${_c[sc]}\e[$_height;0H${_c[f1]}NO CHEATING${_c[res]}"
              is_cheating=1
              continue
            fi
          ;;
          * ) continue ;;
        esac

        echo "$nextex" > "$_exercisefile"
        makelist
        return
      }

      # pressing escape alone will restart the game
      return  
    else
      continue
    fi

    [[ $_activeword = "$_string" ]] && status=$_statuscorrect

    ((status == _oldstatus)) || setstatus $status
    op+="$key"

  done

  ((_resize)) || _restart=0
}
