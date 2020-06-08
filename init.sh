#!/usr/bin/env bash

___printversion(){
  
cat << 'EOB' >&2
typiskt - version: 2020.06.08.16
updated: 2020-06-08 by budRich
EOB
}


# environment variables
: "${XDG_CONFIG_HOME:=$HOME/.config}"


___printhelp(){
  
cat << 'EOB' >&2
typiskt - touchtype training for dirt-hackers


SYNOPSIS
--------
typiskt [--difficulty|-d INT] [--corpus|-c WORDLIST] [--time|-t SECONDS] [--width|-w WIDTH]
typiskt --list|-l
typiskt --help|-h
typiskt --version|-v

OPTIONS
-------

--difficulty|-d INT  

--corpus|-c WORDLIST  

--time|-t SECONDS  

--width|-w WIDTH  

--list|-l  

--help|-h  
Show help and exit.


--version|-v  
Show version and exit.
EOB
}


for ___f in "${___dir}/lib"/*; do
  source "$___f"
done

declare -A __o
options="$(
  getopt --name "[ERROR]:typiskt" \
    --options "d:c:t:w:lhv" \
    --longoptions "difficulty:,corpus:,time:,width:,list,help,version," \
    -- "$@" || exit 77
)"

eval set -- "$options"
unset options

while true; do
  case "$1" in
    --difficulty | -d ) __o[difficulty]="${2:-}" ; shift ;;
    --corpus     | -c ) __o[corpus]="${2:-}" ; shift ;;
    --time       | -t ) __o[time]="${2:-}" ; shift ;;
    --width      | -w ) __o[width]="${2:-}" ; shift ;;
    --list       | -l ) __o[list]=1 ;; 
    --help       | -h ) ___printhelp && exit ;;
    --version    | -v ) ___printversion && exit ;;
    -- ) shift ; break ;;
    *  ) break ;;
  esac
  shift
done

[[ ${__lastarg:="${!#:-}"} =~ ^--$|${0}$ ]] \
  && __lastarg="" 





