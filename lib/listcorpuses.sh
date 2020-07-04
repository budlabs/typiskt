#!/bin/bash

listcorpuses() {
  local d
  [[ -d "${d:=$_sdir/wordlists}" ]] && ls "$d"
  exit
}
