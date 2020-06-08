#!/bin/bash

results() {

  local key

  declare -i clicksum
  clicksum=$((_clicks-_badclicks))
  read -r cpm wpm < <(echo $clicksum "$_time" | awk '{
    wordsum=$1/5
    tid=60/$2
    print (tid * $1), (tid * wordsum)
  }')

  echo -en "${_c[civis]}\e[0;0HCPM: ${cpm}\nWPM: $wpm"

  while :; do
    IFS= read -rsn1 -t 0.007 key || continue

    case "$key" in
      q ) break ;;
      r ) _restart=1 ; break ;;
    esac
    
  done
}
