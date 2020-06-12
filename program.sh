#!/usr/bin/env bash

___printversion(){
  
cat << 'EOB' >&2
typiskt - version: 2020.06.12.1
updated: 2020-06-12 by budRich
EOB
}


# environment variables
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${TYPISKT_SCOREFILE:=$HOME/.cache/typiskt/scorefile}"
: "${TYPISKT_TIME_FORMAT:="%y/%m/%d"}"


main() {

  _source="$(readlink -f "${BASH_SOURCE[0]}")"
  _dir="${_source%/*}"

  ((__o[list])) && listcorpuses

  declare -i _height _width _maxW _difficulty
  declare -i _activepos _nextpos _lastpos
  declare -i _time _t _oldstatus
  declare -i _restart=1 _clicks=0 _badclicks=0
  declare -i _seed

  declare -a wordlist  # wordlist as array
  declare -a words     # ${wordlist[${words[-1]}]}=next
  declare -a specials  # specialsfile as array
  declare -a nextline activeline

  : "${_seed:=${__o[seed]:-$(od -An -N3 -i /dev/random)}}"
  RANDOM=$_seed

  initscreen

  declare -A pos
  pos[pY]=$(( (_height/2) - 2))
  pos[aY]=$(( pos[pY]+3 ))
  pos[aX]=$(( (_width/2) - (_maxW/2) ))
  pos[tY]=$(( pos[aY]+3 ))
  pos[tX]=$(( (_width/2) - (5/2) ))

  declare -A _c
  for k in {0..7}; do 
    _c[f$k]=$(tput setaf "$k")
    _c[b$k]=$(tput setab "$k")
  done
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

  while ((_restart)); do
    while ((_restart)); do starttest ; done
    results
  done

}

___printhelp(){
  
cat << 'EOB' >&2
typiskt - touchtype training for dirt-hackers


SYNOPSIS
--------
typiskt [--difficulty|-d INT] [--corpus|-c WORDLIST] [--time|-t SECONDS] [--width|-w WIDTH] [--seed|-s INT]
typiskt --list|-l
typiskt --help|-h
typiskt --version|-v

OPTIONS
-------

--difficulty|-d INT  

--corpus|-c WORDLIST  

--time|-t SECONDS  

--width|-w WIDTH  

--seed|-s INT  

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

hcat() {

  while getopts :s: o ; do 
    [[ -n $o ]] && spacing=${OPTARG} ; shift 2
  done

  awk -v spacing="${spacing:-1}" '

    BEGIN { id=0 }

    FNR == 1 && FNR != NR {

      lengths[id]+=lengths[last]+spacing
      space=sprintf("%"lengths[id]"s"," ")
      last = id ; id++

      for (line in files[last]) {
        files[id][line] = files[last][line] space
      }

    }

    lengths[id] < length() {lengths[id]=length()}
    id != 0 {
      if (FNR in files[last])
        r=sprintf("%-"lengths[last]"s",files[last][FNR])
      else
        r = space
      sub(/^/,r)
    }
    {files[id][FNR] = $0}

    END {
      for (line in files[id]) {
        print files[id][line]
      }
    }

  ' "$@"
}

highscore() {
  local f=$TYPISKT_SCOREFILE tmp wpm=$1 score=$2
  declare -i t=$EPOCHSECONDS i

  [[ -n $f ]] && {

    tmp=$(mktemp)

    mkdir -p "${f%/*}"

    echo "$score $wpm $t" >> "$f"
    sort -n "$f" > "$tmp" && mv -f "$tmp" "$f"

    mapfile -t tt < "$f"

    local c ct cs
    while ((${#tt[@]} && i++ <= 5)); do
      c=${tt[-1]#* } ct=${c#* } cs=${c% *}
      ((ct == t)) && echo -en "${_c[b2]}"
      printf '%6.2f ' "$cs"
      echo -n "$(date -d @"$ct" +"$TYPISKT_TIME_FORMAT")"
      echo -e "${_c[res]} ▎"
      unset 'tt[-1]'
    done
  }
}
# ▕   ▎ 

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
  op+="\e[${pos[pY]};0H${blank}\e[${pos[pY]};${pos[pX]}H"

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

  declare -i clicksum bh bw 

  clicksum=$((_clicks-_badclicks))

  local key block acc

  tput clear
  tput civis
# 093600
  # 37 6  -- 73992
  wpm=$(bc -l <<< "scale=2;($clicksum/$_time)*12")
  acc=$(bc -l <<< "scale=2;(100-($_badclicks/$clicksum)*100)")
  score=$(bc  <<< "$wpm*$acc")

  notify-send "$score"

  # unset 'numfiles[@]'
  # wpmr=${wpm%$wpmd}
  # declare -a numfiles
  # for ((i=0;i<${#wpmr};i++)) ; do
  #   fil="$_dir/DOSrebel/${wpmr:$i:1}"
  #   [[ -f $fil ]] && numfiles+=("$fil")
  # done

  # fglt=$(hcat "${numfiles[@]}")

  block=$(
    printf 'WPM:       %6.2f\n' "$wpm"
    printf 'Accuracy: %6.1f%% ' "$acc"
    echo -ne "(${_c[f2]}$clicksum${_c[res]}"
    echo -e  "|${_c[f1]}$_badclicks${_c[res]})\n"
    echo
    echo "press 'escape' to restart"
    echo "or 'Q' to quit"
  )

  if ((_time >= 60)); then
    :
    highscore "$wpm"
  else
    block=$(hcat -s 1 <(highscore "$wpm" "$score") <(echo "$block"))
    :
    # no high schore
  fi

  bw=$(wc -L <<< "$block")
  bx=$(( (_width/2) -  (bw/2) ))
  bi=$(printf "%${bx}s" " ")

  block=$(sed "s/^/${bi}/g" <<< "$block")

  # need separate count because hidden chars
  bw=$(wc -L <<< "$fglt") 
  bx=$(( (_width/2) -  (bw/2) ))
  bi=$(printf "%${bx}s" " ")
  fglt=$(sed "s/^/${bi}/g" <<< "$fglt")
  block="$block"

  bh=$(wc -l <<< "$block")
  by=$(( (_height/2) - (bh/2) ))

  echo -en "\e[${by};0H${block}"

  while :; do
    IFS= read -rsn1 -t 0.007 key || continue

    if [[ $key = $'\u1b' ]]; then
      read -rsn2 -t 0.001 && continue 
      _restart=1 ; break
    elif [[ $key = Q ]]; then
      break
    fi
 
  done
  tput clear
}

setline() {
  # copies nextline to activeline
  # call makeline to create new nextline
  # clear both old lines and print the two new ones

  local k

  ((pos[aX])) && indent="$(printf "%${pos[aX]}s" " ")"

  unset 'activeline[@]'

  for k in "${!nextline[@]}"; do
    activeline[$k]=${nextline[$k]}
    _lastpos=$k
  done

  _nextpos=0
  makeline

  op+="\e[${pos[aY]};0H$blank\n${blank}\e[${pos[aY]};0H"
  op+="$indent${activeline[*]}\n"
  op+="$indent${nextline[*]}"

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

  # changes color of "_activeword"
  # 1=red, 2=green, 3=yellow

  local style status=$1

  style="${_c[f$status]}${_activeword}${_c[res]}"
  op+="\e[${pos[aY]};$((_activepos+1+pos[aX]))H${style}"
  op+="\e[${pos[pY]};$((pos[pX]+${#_string}))H"

  _oldstatus=$status
}

starttest() {

  local key ts
  declare -i start=0 lasttime=-1 status

  _clicks=0  _badclicks=0
  _prompt="" _string=""

  # prompt floor
  local f 
  declare -i fx fy
  declare -i fw=14   # floor width

  f=$(printf "%${fw}s" " ")  f=${f// /─}
  fx=$(( (_width/2) - (fw/2) )) fy=$((pos[pY]+1))
  pos[pX]=$((fx+1))

  op="\e[${fy};${fx}H$f"
  
  randomize $((_time*9))
  makeline
  setline
  nextword
  timer

  while : ; do

    ((start)) && ((SECONDS>_t)) && break
    [[ -n $op ]] && {
      echo -en "$op"
      op=""
    }
    ((start)) && ((SECONDS != lasttime)) && timer
    
    # https://stackoverflow.com/a/46481173
    IFS= read -rsn1 -t 0.01 key || continue

    # pressing escape will restart the game
    if [[ $key = $'\u1b' ]]; then
      read -rsn2 -t 0.001 && continue 
      # read above, to catch arrowkeys etc
      return

    # https://askubuntu.com/a/299469
    # backspace key
    elif [[ $key = $'\177' ]]; then
      ((${#_string}<1)) && continue
      _prompt+=$'\b \b'
      _string=${_string:0:-1}

      ts="$_string"

      # hack to allow special chars in regex
      [[ ${_string} =~ [][}{\(^$\\] ]] \
        && ts=$(printf '%q' "$_string")
      [[ "$_activeword" =~ ^${ts} ]] && status=3 || status=1

      # penalty for erasing good char
      ((_oldstatus == 1)) || ((_badclicks++))
      

    # any graphical character
    elif [[ $key =~ [[:graph:]] ]]; then
      _prompt+=$key
      _string+=$key

      ((start)) || { start=1 ; _t=$((_time+SECONDS)) ;}
      nextchar=${_activeword:$((${#_string}-1)):1}

      [[ $key = "$nextchar" ]] \
        && status=$_oldstatus || status=1

      ((_clicks++))
      ((status == 1)) && ((_badclicks++))

    # space, submit word (empty $key == Enter)
    elif [[ $key = " " || -z $key ]]; then
      ((_clicks++))
      ((_oldstatus != 2)) && {
        ((_badclicks++)) 
        ((_activepos == _lastpos)) || setstatus 1
        sl=${#_string}
        cl=$((sl>_activelength?sl:_activelength))
        for ((i=0;i<cl;i++)); do
          c1=${_string:$i:1} c2=${_activeword:$i:1}
          [[ $c1 = "$c2" ]] || ((_badclicks++))
        done
      }
      nextword
      continue
    else
      continue
    fi

    [[ $_activeword = "$_string" ]] && status=2

    ((start)) || { start=1 ; _t=$((_time+SECONDS)) ;}
    ((status == _oldstatus)) || setstatus $status
    op+="\e[${pos[pY]};${pos[pX]}H${_prompt}"

  done

  _restart=0
}

timer() {
  declare -i m s remaining 

  remaining=$((_t-SECONDS))
  ((lasttime==-1)) && remaining=$((_time))
  m=$(( remaining/60 ))
  s=$(( remaining%60 ))

  op+="${_c[civis]}${_c[sc]}"
  op+="\e[${pos[tY]};${pos[tX]}H$(printf '%02d:%02d' $m $s)"
  op+="${_c[cnorm]}${_c[rc]}"

  lasttime=$SECONDS

}

declare -A __o
options="$(
  getopt --name "[ERROR]:typiskt" \
    --options "d:c:t:w:s:lhv" \
    --longoptions "difficulty:,corpus:,time:,width:,seed:,list,help,version," \
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
    --seed       | -s ) __o[seed]="${2:-}" ; shift ;;
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


