#!/usr/bin/env bash

___printversion(){
  
cat << 'EOB' >&2
typiskt - version: 2020.07.05.12
updated: 2020-07-05 by budRich
EOB
}


# environment variables
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${TYPISKT_CONFIG_DIR:=$XDG_CONFIG_HOME/typiskt}"
: "${TYPISKT_CACHE:=$HOME/.cache/typiskt}"
: "${TYPISKT_TIME_FORMAT:="%y/%m/%d"}"
: "${TYPISKT_WIDTH:=50}"
: "${TYPISKT_WORDLIST:=english}"
: "${TYPISKT_MIN_ACC:=96}"
: "${TYPISKT_MIN_WPM:=0}"


# dependencies
__deps=( bash  bc  gawk  paste  wc  getopt )


___printhelp(){
  
cat << 'EOB' >&2
typiskt - touchtype training for dirt-hackers


SYNOPSIS
--------
typiskt [--corpus|-c WORDLIST] [--difficulty|-d INT] [--time|-t SECONDS] [--width|-w WIDTH] [--seed|-s INT]
typiskt --book|-b TEXTFILE [--difficulty|-d INT] [--time|-t SECONDS] [--width|-w WIDTH]
typiskt --source|-u TEXTFILE [--width|-w WIDTH]
typiskt --exercise|-e EXERCISE [--width|-w WIDTH]
typiskt --list|-l
typiskt --help|-h
typiskt --version|-v

OPTIONS
-------

--corpus|-c WORDLIST  
changes WORDLIST to use in the default (words)
mode. Defaults to english. This value can also be
set in TYPISKT_CONFIG_DIR/config or with the
environment variable TYPISKT_WORDLIST.


--difficulty|-d INT  
INT must be a number 0-10, the higher the
difficulty the more often a wordmask will be
applied to words in modes that supports
--difficulty (words|book).


--time|-t SECONDS  
Number of seconds a test will last in modes that
supports --time (words|book). Defaults to 60.


--width|-w WIDTH  
Maximum width in columns for lines. Defaults to:
min(50,COLUMNS-2)


--seed|-s INT  
Seed to be used for RANDOM. Defaults to $(od -An
-N3 -i /dev/random)


--book|-b TEXTFILE  
Sets mode to book and uses TEXTFILE as a
wordlist.


--source|-u TEXTFILE  
Sets mode to source and uses TEXTFILE as a
wordlist.


--exercise|-e EXERCISE  
Sets mode to exercise and looks in
TYPISKT_CONFIG_DIR/exercises/EXERCISE for files to
generate wordlists.


--list|-l  
List available wordlists in WORDLIST_DIR
(defaults to /usr/share/typiskt/wordlist or
SCRIPTDIR/wordlists).


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
    --options "c:d:t:w:s:b:u:e:lhv" \
    --longoptions "corpus:,difficulty:,time:,width:,seed:,book:,source:,exercise:,list,help,version," \
    -- "$@" || exit 77
)"

eval set -- "$options"
unset options

while true; do
  case "$1" in
    --corpus     | -c ) __o[corpus]="${2:-}" ; shift ;;
    --difficulty | -d ) __o[difficulty]="${2:-}" ; shift ;;
    --time       | -t ) __o[time]="${2:-}" ; shift ;;
    --width      | -w ) __o[width]="${2:-}" ; shift ;;
    --seed       | -s ) __o[seed]="${2:-}" ; shift ;;
    --book       | -b ) __o[book]="${2:-}" ; shift ;;
    --source     | -u ) __o[source]="${2:-}" ; shift ;;
    --exercise   | -e ) __o[exercise]="${2:-}" ; shift ;;
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





