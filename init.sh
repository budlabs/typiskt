#!/usr/bin/env bash

___printversion(){
  
cat << 'EOB' >&2
typiskt - version: 2020.06
updated: 2020-06-08 by budRich
EOB
}


# environment variables
: "${XDG_CONFIG_HOME:=$HOME/.config}"


___printhelp(){
  
cat << 'EOB' >&2
typiskt - SHORT DESCRIPTION


SYNOPSIS
--------
typiskt --help|-h
typiskt --version|-v

OPTIONS
-------

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
    --options "hv" \
    --longoptions "help,version," \
    -- "$@" || exit 77
)"

eval set -- "$options"
unset options

while true; do
  case "$1" in
    --help       | -h ) ___printhelp && exit ;;
    --version    | -v ) ___printversion && exit ;;
    -- ) shift ; break ;;
    *  ) break ;;
  esac
  shift
done

[[ ${__lastarg:="${!#:-}"} =~ ^--$|${0}$ ]] \
  && __lastarg="" 





