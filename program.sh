#!/usr/bin/env bash

___printversion(){
  
cat << 'EOB' >&2
typiskt - version: 2020.06
updated: 2020-06-08 by budRich
EOB
}


# environment variables
: "${XDG_CONFIG_HOME:=$HOME/.config}"


main(){

  :
}

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


set -E
trap '[ "$?" -ne 77 ] || exit 77' ERR

ERM(){

  local mode OPTIND

  getopts xr mode
  case "$mode" in
    x ) urg=critical ; prefix='[ERROR]: '   ;;
    r ) urg=low      ; prefix='[WARNING]: ' ;;
    * ) urg=normal   ; mode=m ;;
  esac
  shift $((OPTIND-1))

  msg="${prefix}$*"

  if [[ -t 2 ]]; then
    echo "$msg" >&2
  else
    notify-send -u "$urg" "$msg"
  fi

  [[ $mode = x ]] && exit 77
}

ERX() { ERM -x "$*" ;}
ERR() { ERM -r "$*" ;}
ERH(){
  {
    ___printhelp 
    [[ -n "$*" ]] && printf '\n%s\n' "$*"
  } >&2 
  exit 77
}

__=""
__stdin=""

read -N1 -t0.01 __  && {
  (( $? <= 128 ))  && {
    IFS= read -rd '' __stdin
    __stdin="$__$__stdin"
  }
}

YNP() {

  local sp key default opts status

  default=y
  opts=yn

  [[ $1 =~ -([${opts}]) ]] \
    && default="${BASH_REMATCH[1]}" && shift

  sp="$* [${default^^}/${opts/$default/}]"

  if [[ -t 2 ]]; then
    >&2 echo "$sp"

    while :; do
      read -rsn 1

      key="${REPLY:-$default}"
      [[ $key =~ [${opts}] ]] || continue
      break
    done
  else
    key="$default"
  fi

  [[ ${key,,} = n ]] && status=1

  return "${status:-0}"
}

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


main "${@:-}"


