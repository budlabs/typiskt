#!/bin/bash

results() {

  declare -i clicksum bh bw nextex time bm

  time=$((_time?_time:SECONDS-_start))
  clicksum=$((_clicks-_badclicks>1?_clicks-_badclicks:1))

  local key wpm block acc msg=""

  tput civis

  acc=$(bc -l <<< "scale=3;(100-($_badclicks/$clicksum)*100)")
  wpm=$(bc -l <<< "scale=2;($clicksum/$time)*12")
  [[ ${acc:0:1} = - ]] && acc=0.0
  
  [[ -f $_bookmarkfile ]] && {
    bm=$(( (_bookmark+_words)-1))
    while ((bm > ${#wordlist[@]}-1 )); do ((bm-=${#wordlist[@]} )) ; done
    echo "$bm" > "$_bookmarkfile"
  }

  case "$_mode" in

    ( source )
      declare filename=${_o[source]##*/}
      msg+="$filename containing ${_words} words\n"
      msg+="was typed in $time seconds\n\n"
      msg+="with an average WPM of ${wpm}\n"
      msg+="${acc:0:-2}% accurate."

      msg+="\n\n"

      local lwpm=0.0
      local flwpm=$TYPISKT_CACHE/$_listhash

      [[ -f $flwpm ]] && lwpm=$(< "$TYPISKT_CACHE/$_listhash")
      if (( ${wpm/./} < ${lwpm/./} )); then
        msg+="highest WPM on this file: ${lwpm}"
      else
        msg+="this is your best result"
        echo "$wpm" > "$flwpm"
      fi

      tput clear
      msg=$(centerblock "$msg")
    ;;

    ( exercise )

      declare -i apass wpass

      apass=$((!TYPISKT_MIN_ACC || ${acc%.*} > TYPISKT_MIN_ACC ))
      wpass=$((!TYPISKT_MIN_WPM || ${wpm%.*} > TYPISKT_MIN_WPM ))
      
      ((apass && wpass)) && {
        nextex=$((_lastexercise+1<${#exercises[@]}
                 ?_lastexercise+1:0))
        
        echo "$nextex" > "$_exercisefile"
        echo "$wpm" > "$TYPISKT_CACHE/$_listhash"
      }

      msg=" accuracy: "
      ((apass)) && msg+="${_c[f2]}" || msg+="${_c[f1]}"
      msg+="${acc:0:-2}%${_c[res]}"

      msg+=" | WPM: "
      ((wpass)) && msg+="${_c[f2]}" || msg+="${_c[f1]}"
      msg+="$wpm${_c[res]}"

      msg+="\n press escape "
      ((apass && wpass)) \
        && msg+="for next exercise"   \
        || msg+="to restart exercise"

      msg="\e[$((_height-1));0H$msg"
      
      makelist
    ;;

    ( words|book )

      tput clear

      declare -i dif
      dif=${_o[difficulty]:-0}
      score=$(bc <<< "scale=2;100*((($wpm*$acc)/100)+1+$dif)")
      score=${score%.*}

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

      # don't print highscore in narrow windows
      (( bw > (_width-2) )) && comb="$block"

      msg=$(centerblock "$comb")
    ;;

  esac

  echo -en "$msg"

  while :; do
    IFS= read -rsn1 key || continue

    if [[ $key = $'\u1b' ]]; then
      read -rsn2 -t 0.001 && continue 
      _restart=1 ; break
    elif [[ $key = Q ]]; then
      break
    fi
 
  done
  tput clear
}
