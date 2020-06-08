#!/bin/bash

results() {

  # --- (0 s left) ---
  # CPS (chars per second): 5.9
  # WPM (words per minute): 70.6
  # Characters typed:       59 (59|0)
  # Keys pressed:           59
  # Accuracy:               100.0%
  # Correct words:          12
  # Wrong words:            0


  local key

  tput clear

  # shellcheck disable=SC1004
  cps=$(echo "$_badclicks" "$_clicks" "$_time" | awk '{

    badclicks=$1
    clicks=$2
    time=$3
    
    clicksum=clicks-badclicks
    if (clicksum < 1) {
      wordsum=0
      cps=0
      wpm=0
      accuracy=0
    } else {
      wordsum=clicksum/5
      cps=clicksum/time
      wpm=cps*12
      accuracy=(100-(badclicks/clicksum)*100)
    }
    

    printf("CPS (chars per second): %.1f\n", cps) > "/dev/stderr"
    printf("WPM (words per minute): %.1f\n",wpm) > "/dev/stderr"
    printf("Characters typed:       %d (%s%d%s|%s%d%s)\n",
            clicksum, c2, clicks, cr, c1, badclicks, cr) > "/dev/stderr"
    printf("Accuracy:               %d%%\n",accuracy) > "/dev/stderr"

    printf("%.1f", wpm)

  }' c1="${_c[f1]}" c2="${_c[f2]}" cr="${_c[res]}" )

  echo -en "${_c[civis]}\e[8;0HCPSSSSS: ${cps}"

  while :; do
    IFS= read -rsn1 -t 0.007 key || continue

    case "$key" in
      Q ) break ;;
      R ) _restart=1 ; break ;;
    esac
    
  done
}
