#!/bin/bash

makelist() {
  local list
  list="$_dir/wordlists/${__o[corpus]:-english}"
  [[ -f $list ]] || ERX "cannot find $list"
  
  mapfile -t wordlist < "$list"
}



