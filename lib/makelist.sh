#!/bin/bash

makelist() {

  local list

  if [[ -n ${__o[book]} ]]; then
    list="$_dir/text/${__o[book]}"
    [[ -f $list ]] || ERX "cannot find $list"
    notify-send "$list"
    mapfile -t wordlist < <(tac "$list")
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



