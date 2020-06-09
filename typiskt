#!/usr/bin/env bash

___printversion(){
  
cat << 'EOB' >&2
typiskt - version: 2020.06.10.0
updated: 2020-06-10 by budRich
EOB
}


# environment variables
: "${XDG_CONFIG_HOME:=$HOME/.config}"


main() {

  _source="$(readlink -f "${BASH_SOURCE[0]}")"
  _dir="${_source%/*}"

  ((__o[list])) && listcorpuses

  declare -i _height _width _maxW _difficulty
  declare -i _activepos _nextpos _lastpos
  declare -i _time _t _oldstatus
  declare -i _restart=1 _clicks=0 _badclicks=0

  declare -a wordlist  # wordlist as array
  declare -a words     # ${wordlist[${words[-1]}]}=next
  declare -a specials  # specialsfile as array
  declare -a nextline activeline

  RANDOM=$(od -An -N3 -i /dev/random)

  initscreen

  declare -A pos
  pos[pY]=$(( (_height/2) - 2))
  pos[aY]=$(( pos[pY]+3 ))
  pos[aX]=$(( (_width/2) - (_maxW/2) ))
  pos[tY]=$(( pos[aY]+3 ))
  pos[tX]=$(( (_width/2) - (5/2) ))

  declare -A _c
  for k in {0..7}; do _c[f$k]=$(tput setaf "$k"); done
  _c[res]=$(tput sgr0)
  _c[sc]=$(tput sc)
  _c[rc]=$(tput rc)
  _c[civis]=$(tput civis)
  _c[cnorm]=$(tput cnorm)

  : "${_time:=${__o[time]:-60}}"
  
  blank=$(printf "%${_width}s" " ")

  makelist
  _difficulty=$(( __o[difficulty] < 1  ? 0 : 
                  __o[difficulty] < 11 ? __o[difficulty] :
                  __o[difficulty] > 10 ? 10 : 0 ))

  ((_difficulty)) && {
    mapfile -t specials < "$_dir/specials"
    _difficulty=$(( ${#specials[@]} * ((11-_difficulty) +4) ))
  }

  while : ; do
    while ((_restart)); do starttest ; done

    results
    ((_restart)) || break
  done

}

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


cleanup() {
  # clear out standard input
  read -rt 0.001 && cat </dev/stdin>/dev/null

  # tput reset
  tput rmcup
  tput cnorm
  stty echo
  tput sgr0
  exit 0
}

set -E
trap '[ "$?" -ne 77 ] || exit 77' ERR

ERX() { >&2 echo  "[ERROR] $*" ; exit 77 ;}
ERR() { >&2 echo  "[WARNING] $*" ;}
ERM() { >&2 echo  "$*" ;}
ERH(){
  ___printhelp >&2
  [[ -n "$*" ]] && printf '\n%s\n' "$*" >&2
  exit 77
}

initscreen() {

  read -r _height _width < <(stty size)

  # max width, set with -w or default to width-2
  : "${_maxW:=${__o[width]:-$_width}}"
  _maxW=$(((_width-2)<_maxW?_width-2:_maxW))

  stty -echo
  tput smcup
  tput civis
  tput clear

  trap cleanup HUP TERM EXIT INT
}

listcorpuses() {
  ls "$_dir/wordlists" >&2
  exit
}

makelist() {
  local list
  list="$_dir/wordlists/${__o[corpus]:-english}"
  [[ -f $list ]] || ERX "cannot find $list"
  
  mapfile -t wordlist < "$list"
}




nextword() {

  ((_activepos == _lastpos)) && setline

  _activeword=${activeline[$_nextpos]}
  _activelength=${#_activeword}
  _activepos=$_nextpos
  _nextpos=$(( _activepos+(_activelength+1) ))
  setstatus 3

  _prompt=""
  _string=""

  # reset prompt
  echo -en "$op\e[${pos[pY]};0H${blank}\e[${pos[pY]};${pos[pX]}H"

}

randomize() {

  local n last next

  n=${1:-100}
  declare -a nums
  nums=("${!wordlist[@]}")

  for ((i=0; i<n; i++)); do
    next=$((RANDOM%${#nums[@]}))
    ((next == last)) && next=$((RANDOM%${#nums[@]}))
    words+=("${nums[$next]}")
    last=$next
  done
}

results() {

  declare -i clicksum acc bh bw

  clicksum=$((_clicks-_badclicks))

  local key block

  tput clear
  tput civis

  # words per minute 2 point presicion
  wpm=$(bc -l <<< "scale=1
    ( (${clicksum}) / ${_time} )*12
  ")

  # accuracy
  acc=$((100-(_badclicks/clicksum)*100))

  fglt=$(
    figlet -f "DOS Rebel" "$(printf "%.0f" "$wpm")" \
      | sed '/^[[:space:]]*$/ d'
  )

  block=$(
    printf '\n\n%-10s%-4s %s\n' "Speed:" "$wpm" "WPM"
    printf '%-10s%-4s '         "Accuracy:" "$acc%"
    echo -ne "(${_c[f2]}$clicksum${_c[res]}"
    echo -e  "|${_c[f1]}$_badclicks${_c[res]})\n"
    echo '[R]estart'
    echo '[Q]uit'
  )

  bw=$(wc -L <<< "$fglt")
  ((bw<=_maxW)) && block="${fglt}$block" || bw=$_maxW
  bh=$(wc -l <<< "$block")

  # need separate count because hidden chars
  # read -r bh bw < <(wc -lL <<< "$block")
  by=$(( (pos[pY/2]) - (bh/2) ))
  bx=$(( (_width/2) - (bw/2) ))
  
  # add intendation to center horizontally
  bi=$(printf "%${bx}s" " ")
  block=$(sed "s/^/${bi}/g" <<< "$block")
  echo -en "\e[${by};0H${block}"

  while :; do
    IFS= read -rsn1 -t 0.007 key || continue

    case "$key" in
      Q ) break ;;
      R ) _restart=1 ; break ;;
    esac
    
  done
}

setline() {
  # copies nextline to activeline
  # call makeline to create new nextline
  # clear both old lines and print the two new ones

  local k op=""

  ((pos[aX])) && indent="$(printf "%${pos[aX]}s" " ")"

  unset 'activeline[@]'

  for k in "${!nextline[@]}"; do
    activeline[$k]=${nextline[$k]}
    _lastpos=$k
  done

  _nextpos=0
  makeline

  op="\e[${pos[aY]};0H$blank\n${blank}\e[${pos[aY]};0H"
  op+="$indent${activeline[*]}\n"
  op+="$indent${nextline[*]}"

  echo -en "$op"
}

makeline() {

  # creates new nextline array
  # add words to array, as long as they fit in _maxW

  declare -i ll wl j
  local w

  unset 'nextline[@]'

  while :; do
    w=${wordlist[${words[-1]}]}

    ((_difficulty)) && {

      j=$((RANDOM%_difficulty ))
      if [[ -n ${specials[$j]} ]]; then
        w=${specials[$j]/W/$w}
      elif ((j == (${#specials[@]}+1) )); then
        w="$((RANDOM%1111111))"
      elif ((j == (${#specials[@]}+2) )); then
        w=budlabs
      elif ((j == (${#specials[@]}+3) )); then
        w="${w^}"
      elif ((j == (${#specials[@]}+4) )); then
        w="${w^^}"
      fi

    }
   
    wl=${#w}
    (( (ll+=(wl+1)) > _maxW )) && break

    # index in array is also xposition
    nextline+=([$((ll-(wl+1)))]="$w")
    unset 'words[-1]'
    # ((${#words}<1)) && randomize 100
  done

}

setstatus() {

  # changes color of "activeword"
  # 1=red, 2=green, 3=yellow

  local style status=$1

  style="${_c[f$status]}${_activeword}${_c[res]}"
  tput civis
  echo -en "\e[${pos[aY]};$((_activepos+1+pos[aX]))H${style}"
  tput cnorm

  _oldstatus=$status
}

starttest() {

  local key ts
  declare -i start=0 lasttime=-1 status
  _clicks=0 _badclicks=0

  tput clear

  # prompt floor
  local f 
  declare -i fx fy
  declare -i fw=14   # undeline width

  f=$(printf "%${fw}s" " ")  f=${f// /─}
  fx=$(( (_width/2) - (fw/2) )) fy=$((pos[pY]+1))
  pos[pX]=$((fx+1))

  echo -en "\e[${fy};${fx}H$f"
  
  randomize $((_time*9))
  makeline
  setline
  _prompt=""
  _string=""

  nextword
  timer

  while : ; do

    ((start)) && ((SECONDS>_t)) && break
    ((start)) && ((SECONDS != lasttime)) && timer
    
    # https://stackoverflow.com/a/46481173
    IFS= read -rsn1 -t 0.007 key || continue

    if [[ $key = $'\u1b' ]]; then
      read -rsn2 -t 0.001 && continue 
      # pressing escape will restart the game
      # read above, to catch arrowkeys etc
      return
    # https://askubuntu.com/a/299469
    elif [[ $key = $'\177' ]]; then
      ((${#_string}<1)) && continue
      _prompt+=$'\b \b'
      _string=${_string:0:-1}
    elif [[ $key =~ [[:graph:]] ]]; then
      _prompt+=$key
      _string+=$key
    elif [[ $key = " " ]]; then
      ((_clicks++))
      ((_oldstatus != 2)) && {
        ((_badclicks++)) 
        setstatus 1
        sl=${#_string}
        cl=$((sl>$_activelength?sl:_activelength))
        for ((i=0;i<cl;i++)); do
          c1=${_string:$i:1} c2=${_activeword:$i:1}
          [[ $c1 = $2 ]] || ((_badclicks++))
        done
        # bads=$((${#_string} - _activelength))
        # ((_badclicks+=(bads<0 ? bads*-1 : bads) ))
      }
      nextword
      continue
    else
      continue
    fi

    ((start)) || { start=1 ; _t=$((_time+SECONDS)) ;}

    nextchar=${_activeword:$((${#_string}-1)):1}

    if [[ $_activeword = "$_string" ]]; then
      status=2
    elif [[ $key = "$nextchar" ]]; then
      status=3
    elif [[ $key = $'\177' ]]; then
      ts="$_string"
      # don't erase a good character
      ((status == 1)) || ((_badclicks++))
      # hack to allow special chars in regex
      [[ ${_string} =~ [][}{\(^$\\] ]] \
        && ts=$(printf '%q' "$_string")
      [[ "$_activeword" =~ ^${ts} ]] && status=3 || status=1
    else # don't match
      status=1
    fi

    [[ $key = $'\177' ]] || {
      ((_clicks++))
      ((status == 1)) && ((_badclicks++))
    }

    ((status == _oldstatus)) || setstatus $status
    echo -en "\e[${pos[pY]};${pos[pX]}H${_prompt}"

  done

  _restart=0
}

timer() {
  declare -i m s t 
  local op=""
  t=$((_t-SECONDS))
  ((lasttime==-1)) && t=$((_time))
  m=$(( t/60 ))
  s=$(( t%60 ))

  op+="${_c[civis]}${_c[sc]}"
  op+="\e[${pos[tY]};${pos[tX]}H$(printf '%02d:%02d' $m $s)"
  op+="${_c[cnorm]}${_c[rc]}"
  echo -en "$op"

  lasttime=$SECONDS

}

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


main "${@:-}"


