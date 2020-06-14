#!/bin/bash

makelist() {

  local list

  if [[ -n ${__o[source]} ]]; then
    list=${__o[source]}
    [[ -f $list ]] || ERX "cannot find $list"
    mapfile -t wordlist < <(wordsfromfile "$list")
    __o[width]=$(wc -L < "$list")
    # exit
  elif [[ -n ${__o[book]} ]]; then
    list="$_dir/text/${__o[book]}"
    [[ -f $list ]] || ERX "cannot find $list"
    mapfile -t wordlist < "$list"
    _bookmarkfile=$TYPISKT_CACHE/bookmarks/${__o[book]}
    [[ -f $_bookmarkfile ]] || {
      mkdir -p "${_bookmarkfile%/*}"
      echo 0 > "$_bookmarkfile"
    }
  else
    list="$_dir/wordlists/${__o[corpus]:-english}"
    [[ -f $list ]] || ERX "cannot find $list"
    mapfile -t wordlist < "$list"
  fi
 
}



