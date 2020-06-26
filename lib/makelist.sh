#!/bin/bash

makelist() {

  local list exd exf tmpf exh
  tmpf=$(mktemp)

  case "$_mode" in

    words ) list="$_dir/wordlists/${__o[corpus]:-english}" ;;

    ( book )
      # list="$_dir/text/${__o[book]}"
      list=${__o[book]}
      [[ -f $list ]] || ERX "cannot find $list"
      wordsfromfile "$list" > "$tmpf"
      list=$tmpf
    ;;

    ( source )
      list=${__o[source]}
      [[ -f $list ]] || ERX "cannot find $list"
      __o[width]=$(wc -L < "$list")
      wordsfromfile "$list" > "$tmpf"
      list=$tmpf
    ;;

    ( exercise )
      # exd - shorthand for exercise directory/name 
      # exf - shorthand for exercise file/number

      [[ -d ${exd:=${__o[exercise]}} ]] \
        || ERX could not find exercise "$exd"

      exd=$(readlink -f "$exd")
      exh=$(echo -n "$exd" | md5sum | cut -f1 -d' ')
      # file to store index of last exercise
      _exercisefile=$TYPISKT_CACHE/$exh

      # if ARG to --exercise is a directory
      # all files in the dir is added to 'exercises'
      # array. _lastexercise will be either the
      # content of _exercisefile or 0
      # exf=${exercises[$_lastexercise]}

      [[ -f $exf ]] || {
        _lastexercise=0
        [[ -f $_exercisefile ]] \
          && _lastexercise=$(< "$_exercisefile")

        < <(find "$exd" -type f -printf '%f\n' | sort -n) \
          mapfile -t exercises 

        exf="$exd/${exercises[$_lastexercise]}"
      }

      list="$exf"
    ;;
  esac

  [[ -f $list ]] || ERX "cannot find $list"
  _listhash=$(md5sum "$list" | cut -f1 -d' ')
  mapfile -t wordlist < "$list"
  rm "$tmpf"
}
