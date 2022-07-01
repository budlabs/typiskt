#!/bin/bash

initscreen() {

  stty -echo
  tput smcup
  tput civis

  _gotscreen=1

  trap 'resize' SIGWINCH
}

resize() {

  local margin=2 padding=2 needed=3
  local layout layout_height tmpH tmpW

  read -r tmpH tmpW < <(stty size)

  ((_height == tmpH && _width == tmpW)) && return  
  _height=$tmpH _width=$tmpW

  tput clear

  unset 'lines[@]'

  _maxW=${_o[width]:-$TYPISKT_WIDTH}
  _maxW=$(( (_width-2)<_maxW?_width-2:_maxW ))

  _number_of_lines=${_o[lines]:-$TYPISKT_LINES}
  ((_number_of_lines < 1)) && _number_of_lines=2

  layout_height=$((margin+padding+_number_of_lines+needed))

  for layout in full comfy compact minimal; do
    case "$layout" in

      full    ) # lines+needed+margin+padding
        padding=1
        ((layout_height-0 <= _height)) || continue
        margin=$(( 1 + (_height-(_number_of_lines+needed+padding))/2 ))
        break
        ;;

      comfy   ) # lines+needed+padding
        margin=0
        ((layout_height-2 <= _height)) && break
        ;;

      compact ) # lines+needed
        padding=0
        ((layout_height-4 <= _height)) && break
        ;;

      minimal ) _number_of_lines=$((_height-needed)) ;;

    esac
  done

  pos[pY]=$margin                               # prompt
  pos[fY]=$((pos[pY]+1))                        # underline
  pos[aY]=$((pos[fY]+padding+1))                # first line
  pos[tY]=$((pos[aY]+padding+_number_of_lines)) # timer

  pos[aX]=$(( (_width/2) - (_maxW/2) ))
  pos[tX]=$(( (_width/2) - (5/2) ))
  pos[fX]=$(( (_width/2) - (_underlinewidth/2) ))
  pos[pX]=$(( pos[fX]+1 ))

  local f
  f=$(printf "%${_underlinewidth}s" " ")  f=${f// /─}
  _underline="\e[${pos[fY]};${pos[fX]}H$f"

  ((pos[aX])) && _activeindent="$(printf "%${pos[aX]}s" " ")"
  blank=$(printf "%${_width}s" " ")
  _resize=1
}
