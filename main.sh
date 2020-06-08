#!/usr/bin/env bash

main() {

  declare -a wordlist nextline activeline

  RANDOM=$(od -An -N3 -i /dev/random)

  declare -i height width

  declare -i activepos nextpos lastpos _t
  declare -i status oldstatus lasttime=-1
  declare -i restart=1 clicks=0 badclicks=0 

  declare -A pos

  declare -i _maxW=50
  declare -i _time=20

  mapfile -t specials < "$___dir/specials"

  initscreen

  blank=$(printf "%${width}s" " ")

  declare -A _c
  for k in {1..6}; do _c[f$k]=$(tput setaf $k); done
  _c[res]=$(tput sgr0)
  _c[sc]=$(tput sc)
  _c[rc]=$(tput rc)
  _c[civis]=$(tput civis)
  _c[cnorm]=$(tput cnorm)

  while ((restart)); do starttest ; done

  clicksum=$((clicks-badclicks))
  read -r cpm wpm < <(echo $clicksum $_time | awk '{
    wordsum=$1/5
    tid=60/$2
    print (tid * $1), (tid * wordsum)
  }')
  # wordsum=$((clicksum/5))

  echo -en "\e[0;0H${cpm}\n$wpm"
  sleep 3
  read -rsn 1


}

___source="$(readlink -f "${BASH_SOURCE[0]}")"  #bashbud
___dir="${___source%/*}"                        #bashbud
source "$___dir/init.sh"                        #bashbud
main "${@}"                                     #bashbud
