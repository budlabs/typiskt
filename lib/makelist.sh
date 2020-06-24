#!/bin/bash

makelist() {

  local list ex exf exd exl

  if [[ -n ${__o[source]} ]]; then
    list=${__o[source]}
    [[ -f $list ]] || ERX "cannot find $list"
    mapfile -t wordlist < <(wordsfromfile "$list")
    __o[width]=$(wc -L < "$list")

  elif [[ -n ${exd:=${__o[exercise]}} ]]; then
    [[ -f $exd ]] && exf=$exd && exd=${exf%/*}
    [[ -d $exd ]] || ERX could not find exercise "$exd"

    _exercisefile=$TYPISKT_CACHE/excersices/$exd

    [[ -f $exf ]] || {
      _lastexercise=0
      [[ -f $_exercisefile ]] && _lastexercise=$(< "$_exercisefile")
      < <(find "$exd" -type f -printf '%f\n' | sort -n) \
        mapfile -t exercises 

      exf="$exd/${exercises[$_lastexercise]}"
      mkdir -p "${_exercisefile%/*}"
      echo "$_lastexercise" > "$_exercisefile"
    }

    [[ -f $exf ]] || ERX could not find exercise "$exf"
    mapfile -t wordlist < "$exf"

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



