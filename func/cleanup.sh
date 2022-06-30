#!/bin/bash

trap cleanup HUP TERM EXIT INT

cleanup() {

  # this function gets triggered on both EXIT INT
  # causing it to get triggered twice on ctrl+c
  # therefor testing existence of _tmpE (ERR.sh)
  [[ -f $_tmpE ]] && {

    ((_gotscreen)) && {
      # clear out standard input
      read -rt 0.001 && cat </dev/stdin>/dev/null

      tput rmcup
      tput cnorm
      tput sgr0
    }
    
    >&2 cat "$_tmpE"
    rm "${_tmpE:?}"
  }
  
  stty echo
  exit 77
}
