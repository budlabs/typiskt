#!/bin/bash

highscore() {
  local f=$TYPISKT_SCOREFILE tmp wpm=$1 score=$2
  declare -i t=$EPOCHSECONDS i

  [[ -n $f ]] && {

    tmp=$(mktemp)

    mkdir -p "${f%/*}"

    echo "$score $wpm $t" >> "$f"
    sort -n "$f" > "$tmp" && mv -f "$tmp" "$f"

    mapfile -t tt < "$f"

    local c ct cs
    while ((${#tt[@]} && i++ <= 5)); do
      c=${tt[-1]#* } ct=${c#* } cs=${c% *}
      ((ct == t)) && echo -en "${_c[b2]}"
      printf '%6.2f ' "$cs"
      echo -n "$(date -d @"$ct" +"$TYPISKT_TIME_FORMAT")"
      ((ct == t)) && echo -ne "${_c[res]}"
      echo " ▎"
      unset 'tt[-1]'
    done
  }
}
# ▕   ▎ 
