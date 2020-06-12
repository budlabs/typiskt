#!/bin/bash

results() {

  declare -i clicksum bh bw 

  clicksum=$((_clicks-_badclicks))

  local key block acc

  tput clear
  tput civis
# 093600
  # 37 6  -- 73992
  wpm=$(bc -l <<< "scale=2;($clicksum/$_time)*12")
  acc=$(bc -l <<< "scale=2;(100-($_badclicks/$clicksum)*100)")
  score=$(bc  <<< "$wpm*$acc")

  

  # unset 'numfiles[@]'
  # wpmr=${wpm%$wpmd}
  # declare -a numfiles
  # for ((i=0;i<${#wpmr};i++)) ; do
  #   fil="$_dir/DOSrebel/${wpmr:$i:1}"
  #   [[ -f $fil ]] && numfiles+=("$fil")
  # done

  # fglt=$(hcat "${numfiles[@]}")

  block=$(
    printf 'WPM:       %6.2f\n' "$wpm"
    printf 'Accuracy: %6.1f%% ' "$acc"
    echo -ne "(${_c[f2]}$clicksum${_c[res]}"
    echo -e  "|${_c[f1]}$_badclicks${_c[res]})\n"
    echo
    echo "press 'escape' to restart"
    echo "or 'Q' to quit"
  )

  if ((_time >= 60)); then
    :
    highscore "$wpm"
  else
    block=$(paste -d "" <(highscore "$wpm" "$score") - <<< "$block")
    :
    # no high schore
  fi
 
  bw=$(wc -L <<< "${block}")

  # wc -L "always" report 24 characters more...
  declare -i magic=24

  bx=$(( (_width/2) -  ((bw-magic)/2) ))
  bi=$(printf "%${bx}s" " ")

  block=$(sed "s/^/${bi}/g" <<< "$block")

  # need separate count because hidden chars
  bw=$(wc -L <<< "$fglt") 
  bx=$(( (_width/2) -  (bw/2) ))
  bi=$(printf "%${bx}s" " ")
  fglt=$(sed "s/^/${bi}/g" <<< "$fglt")
  block="$block"

  bh=$(wc -l <<< "$block")
  by=$(( (_height/2) - (bh/2) ))

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
