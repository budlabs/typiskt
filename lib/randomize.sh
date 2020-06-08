#!/bin/bash

randomize() {

  local n last next

  n=${1:-100}
  declare -a nums
  nums=("${!wordlist[@]}")

  for ((i=0; i<n; i++)); do
    next=$((RANDOM%${#nums[@]}))
    ((next == last)) && next=$((RANDOM%${#nums[@]}))
    words+=("${nums[$next]}")
    last=$next
  done
}
