#!/bin/bash
set -E
trap '[ "$?" -ne 77 ] || exit 77' ERR

ERX() { >&2 echo  "[ERROR] $*" ; exit 77 ;}
ERR() { >&2 echo  "[WARNING] $*" ;}
ERM() { >&2 echo  "$*" ;}
ERH(){
  ___printhelp >&2
  [[ -n "$*" ]] && printf '\n%s\n' "$*" >&2
  exit 77
}
