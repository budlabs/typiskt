#!/bin/bash

cleanup() {
  # clear out standard input
  read -rt 0.001 && cat </dev/stdin>/dev/null

  # tput reset
  tput rmcup
  tput cnorm
  stty echo
  tput sgr0
  exit 0
}
