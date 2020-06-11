#!/bin/bash

results() {

  declare -i clicksum bh bw

  clicksum=$((_clicks-_badclicks))

  local key block acc

  tput clear
  tput civis

  # words per minute 2 point presicion
  wpm=$(bc -l <<< "scale=2;(($clicksum)/$_time)*12")

  # accuracy
  acc=$(bc -l <<< "scale=2; 100-(($_badclicks/$clicksum)*100)")

  wpmrounded=$(printf "%.0f" "$wpm")

  unset 'numfiles[@]'
  for ((i=0;i<${#wpmrounded};i++)) ; do
    fil="$_dir/DOSrebel/${wpmrounded:$i:1}"
    [[ -f $fil ]] && numfiles+=("$fil")
  done

  fglt=$(hcat "${numfiles[@]}")

  block=$(
    printf '\n\n%10s %6.1f %s\n' "Speed:" "$wpm" "WPM"
    printf '%10s%6.1f%% '         "Accuracy:" "$acc"
    echo -ne "(${_c[f2]}$clicksum${_c[res]}"
    echo -e  "|${_c[f1]}$_badclicks${_c[res]})\n"
    echo
    echo "press 'escape' to restart"
    echo "      or 'Q' to quit"
  )

  # need separate count because hidden chars
  bw=$(wc -L <<< "$fglt")
  ((bw<=_maxW)) && block="$fglt$block" || bw=$_maxW
  bh=$(wc -l <<< "$block")

  
  by=$(( (_height/2) - (bh/2) ))
  bx=$(( (_width/2) -  (bw/2) ))

  # add intendation to center horizontally
  bi=$(printf "%${bx}s" " ")
  block=$(sed "s/^/${bi}/g" <<< "$block")

  echo -en "\e[${by};0H${block}"

  while :; do
    IFS= read -rsn1 -t 0.007 key || continue

    if [[ $key = $'\u1b' ]]; then
      read -rsn2 -t 0.001 && continue 
      _restart=1 ; break
    elif [[ $key = Q ]]; then
      break
    fi
 
  done
  tput clear
}
