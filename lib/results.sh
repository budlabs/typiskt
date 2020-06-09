#!/bin/bash

results() {

  declare -i clicksum acc bh bw

  clicksum=$((_clicks-_badclicks))

  local key block

  tput clear
  tput civis

  # words per minute 2 point presicion
  wpm=$(bc -l <<< "scale=1
    ( (${clicksum}) / ${_time} )*12
  ")

  # accuracy
  acc=$((100-(_badclicks/clicksum)*100))

  fglt=$(
    figlet -f "DOS Rebel" "$(printf "%.0f" "$wpm")" \
      | sed '/^[[:space:]]*$/ d'
  )

  block=$(
    printf '\n\n%-10s%-4s %s\n' "Speed:" "$wpm" "WPM"
    printf '%-10s%-4s '         "Accuracy:" "$acc%"
    echo -ne "(${_c[f2]}$clicksum${_c[res]}"
    echo -e  "|${_c[f1]}$_badclicks${_c[res]})\n"
    echo '[R]estart'
    echo '[Q]uit'
  )

  bw=$(wc -L <<< "$fglt")
  ((bw<=_maxW)) && block="${fglt}$block" || bw=$_maxW
  bh=$(wc -l <<< "$block")

  # need separate count because hidden chars
  # read -r bh bw < <(wc -lL <<< "$block")
  by=$(( (pos[pY/2]) - (bh/2) ))
  bx=$(( (_width/2) - (bw/2) ))
  
  # add intendation to center horizontally
  bi=$(printf "%${bx}s" " ")
  block=$(sed "s/^/${bi}/g" <<< "$block")
  echo -en "\e[${by};0H${block}"

  while :; do
    IFS= read -rsn1 -t 0.007 key || continue

    case "$key" in
      Q ) break ;;
      R ) _restart=1 ; break ;;
    esac
    
  done
}
