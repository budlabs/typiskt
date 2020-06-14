#!/bin/bash

results() {

  declare -i clicksum bh bw 

  clicksum=$((_clicks-_badclicks))

  local key block acc msg

  tput clear
  tput civis

  wpm=$(bc -l <<< "scale=2;($clicksum/$_time)*12")
  acc=$(bc -l <<< "scale=2;(100-($_badclicks/$clicksum)*100)")
  score=$(bc  <<< "(($wpm*$acc)*(1+$_difficulty)/100)")
  score=${score%.*}

  [[ -f $_bookmarkfile ]] && {
    echo "$((_bookmark+_words))" > "$_bookmarkfile"
  }

  block=$(
    printf 'WPM:      %6.2f\n' "$wpm"
    printf 'accuracy:%6.1f%% ' "$acc"
    echo -ne "(${_c[f2]}$clicksum${_c[res]}"
    echo -e  "|${_c[f1]}$_badclicks${_c[res]})"
  )

  if ((_time >= 60)); then
    ep=$EPOCHSECONDS
    hs=$(highscore "$wpm" "$score" "$ep")
    grep '\*' <<< "$hs" >/dev/null && \
      msg="A winner is (You)!"$'\n\n'

    poss=$(grep -n "$ep" "$TYPISKT_CACHE/scorefile")
    msg+="position: ${poss%%:*}"$'\n'
    msg+="score:    ${score}"
  else
    hs=$(highscore)
    msg=$(printf '%s\n' \
      "tests under 60 seconds" \
      "are not added to the"   \
      "scoreboard"             \
    )
  fi

  block+=$'\n\n'"$msg"

  comb=$(paste -d " " <(echo "$hs") - <<< "$block")
  
  # wc -L "always" report 24 characters more...
  declare -i magic=32

  bw=$(wc -L <<< "${comb}")
  bw=$((bw-magic))

  bx=$(( (_width/2) -  ((bw)/2) ))
  
  # don't print highscore in narrow windows
  (( bw > (_width-2) )) && {
    bx=1
    comb="$block"
  }

  bi=$(printf "%${bx}s" " ")
  comb=$(sed "s/^/${bi}/g" <<< "$comb")
  comb="$comb"

  bh=$(wc -l <<< "$comb")
  by=$(( (_height/2) - (bh/2) ))

  echo -en "\e[${by};0H${comb}"

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
