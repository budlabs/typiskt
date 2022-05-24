#!/bin/bash

wordsfromfile() {
  local f=$1

  declare -i lb=0
  ((_prop & m[linebreak])) && lb=1

  awk -v lb=$lb '
  /./ {
    for (i=1;i<=NF;i++) {
      word=$i
      print word
    }
    if (lb==1) print "@@EOL"
  }
  ' "$f"
}

