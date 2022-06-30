#!/bin/bash

set -E
trap '[ "$?" -ne 77 ] || exit 77' ERR

ERX() { echo  "[ERROR] $*" >> "$_tmpE" ; exit 77 ;}
ERR() { echo  "[WARNING] $*" >> "$_tmpE"  ;}
ERM() { echo  "$*" >> "$_tmpE"  ;}
ERH(){
  ___printhelp >&2
  [[ -n "$*" ]] && printf '\n%s\n' "$*" >&2
  exit 77
}
