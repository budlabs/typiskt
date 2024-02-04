#!/bin/bash

highscore() {
  local f=$TYPISKT_CACHE/scorefile tmp wpm=$1 score=$2
  declare -i t=$3 i

  [[ -n $f ]] && {

    tmp=$(mktemp)

    mkdir -p "${f%/*}"
    [[ -L $f ]] && f=$(readlink -f "$f")

    [[ -n $wpm ]] && {
      echo "$score $wpm $t" >> "$f"
      sort -rn "$f" > "$tmp" && mv -f "$tmp" "$f"
    }

    mapfile -t tt < "$f"
    local c ct cs dummy
    dummy=" 100.99 $(date +"$TYPISKT_TIME_FORMAT")"

    for ((i=0;i<7;i++)); do
      if [[ -n ${tt[$i]} ]]; then
        c=${tt[$i]#* } ct=${c#* } cs=${c% *}
        ((ct == t)) && echo -en "*${_c[b2]}" || echo -n " "
        LC_NUMERIC=C printf '%6.2f ' "$cs"
        echo -n "$(date -d @"$ct" +"$TYPISKT_TIME_FORMAT")"
        ((ct == t)) && echo -ne "${_c[res]}"
        echo "${_c[f4]}▕${_c[res]}"
      else
        echo "${dummy//[^[:space:]]/ }${_c[f4]}▕${_c[res]}"
      fi
    done
  }
}
