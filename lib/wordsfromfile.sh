#!/bin/bash

wordsfromfile() {
  local f=$1

  awk -v sq="'" '
  /\S/ {
    sub(/^\s+$/,"")
    for (i=1;i<NF+1;i++) {
      word=$i
      if(word != "") print word
    }
    print "@@EOL"
  }
  END { print "@@EOF" }
  ' "$f"
}

