#!/bin/bash

centerblock() {

  local b indent=""

  b=$(echo -en "$1")
  declare -i bw bh x y

  read -r bh bw _ < <(wc -lL <<< "$b")
  x=$(( bw>_width  ? 0: (_width/2)-(bw/2)  ))
  y=$(( bh>_height ? 0: (_height/2)-(bh/2) ))

  indent=$(printf "%${x}s" " ")
  b="$indent${b//$'\n'/$'\n'${indent}}"

  echo -en "\e[$y;0H$b"

}
