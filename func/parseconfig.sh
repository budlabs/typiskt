#!/bin/bash

parseconfig() {
  
  local line re sp ns k v

  [[ -f $TYPISKT_CONFIG_DIR/config ]] || {

    checkdependencies
    
    mkdir -p "$TYPISKT_CONFIG_DIR"/exercises
    cp -rf -t "$TYPISKT_CONFIG_DIR"            \
              "$_sdir/config"                  \
              "$_sdir/wordmasks"               \
              "$_sdir/exercises"               
  }

  sp='[[:space:]]' ns='[^[:space:]]'
  re="^$sp*([^#]$ns+)$sp*=$sp*($ns+)$sp*\$"

  while read -r line ; do [[ $line =~ $re ]] && {

    k=${BASH_REMATCH[1]} v=${BASH_REMATCH[2]}

    case "$k" in
      default-wordlist          ) TYPISKT_WORDLIST=$v      ;;
      maxwidth                  ) TYPISKT_WIDTH=$v         ;;
      cache-dir                 ) TYPISKT_CACHE=${v/'~'/~} ;;
      highscore-time-format     ) TYPISKT_TIME_FORMAT=$v   ;;
      exercise-minimum-accuracy ) TYPISKT_MIN_ACC=$v       ;;
      exercise-minimum-wpm      ) TYPISKT_MIN_WPM=$v       ;;
      status-color-error        ) _statuserror=$v         ;;
      status-color-correct      ) _statuscorrect=$v       ;;
      status-color-active       ) _statusactive=$v        ;;
    esac

  } ; done < "$TYPISKT_CONFIG_DIR/config"

  : "${_statuserror:=1}"
  : "${_statuscorrect:=2}"
  : "${_statusactive:=3}"
}
