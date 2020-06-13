#!/usr/bin/env bash

___printversion(){
  
cat << 'EOB' >&2
typiskt - version: 2020.06.13.3
updated: 2020-06-13 by budRich
EOB
}


# environment variables
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${TYPISKT_CACHE:=$HOME/.cache/typiskt}"
: "${TYPISKT_TIME_FORMAT:="%y/%m/%d"}"


main() {

  _source="$(readlink -f "${BASH_SOURCE[0]}")"
  _dir="${_source%/*}"
  _bookmarkfile=""

  ((__o[list])) && listcorpuses

  declare -i _height _width _maxW _difficulty
  declare -i _activepos _nextpos _lastpos
  declare -i _time _t _oldstatus _bookmark
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
typiskt [--difficulty|-d INT] [--book|-b BOOKWORDLIST] [--time|-t SECONDS] [--width|-w WIDTH]
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

--book|-b BOOKWORDLIST  

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

highscore() {
  local f=$TYPISKT_CACHE/scorefile tmp wpm=$1 score=$2
  declare -i t=$3 i

  [[ -n $f ]] && {

    tmp=$(mktemp)

    mkdir -p "${f%/*}"

    [[ -n $wpm ]] && {
      echo "$score $wpm $t" >> "$f"
      sort -rn "$f" > "$tmp" && mv -f "$tmp" "$f"
    }

    mapfile -t tt < "$f"
    local c ct cs dummy
    dummy=" 100.99 $(date +"$TYPISKT_TIME_FORMAT")"

    for ((i=0;i<7;i++)); do
      if [[ -n ${tt[$i]} ]]; then
        c=${tt[$i]#* } ct=${c#* } cs=${c% *}
        ((ct == t)) && echo -en "*${_c[b2]}" || echo -n " "
        printf '%6.2f ' "$cs"
        echo -n "$(date -d @"$ct" +"$TYPISKT_TIME_FORMAT")"
        ((ct == t)) && echo -ne "${_c[res]}"
        echo "${_c[f4]}▕${_c[res]}"
      else
        echo "${dummy//[^[:space:]]/ }${_c[f4]}▕${_c[res]}"
      fi
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

  if [[ -n ${__o[book]} ]]; then
    list="$_dir/text/${__o[book]}"
    [[ -f $list ]] || ERX "cannot find $list"
    mapfile -t wordlist < <(tac "$list")
    _bookmark=$TYPISKT_CACHE/bookmarks/${__o[book]}
    [[ -f $_bookmarkfile ]] && {
      mkdir -p "${_bookmarkfile%/*}"
      echo 0 > "$_bookmarkfile"
    }
  else
    list="$_dir/wordlists/${__o[corpus]:-english}"
    [[ -f $list ]] || ERX "cannot find $list"
    mapfile -t wordlist < "$list"
  fi
 
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
  unset 'words[@]'
  

  if [[ -n ${__o[book]} ]]; then
    # notify-send "$(sort -r < "$_list")"
    [[ -f $_bookmarkfile ]] \
      && _bookmark=$(cat "$_bookmarkfile")

    ((n+=_bookmark))
    while ((${#words[@]} < n)); do
      eval "words=({$_bookmark..$n})"
    done
  else
    declare -a nums
    
    nums=("${!wordlist[@]}")
    for ((i=0; i<n; i++)); do
      next=$((RANDOM%${#nums[@]}))
      ((next == last)) && next=$((RANDOM%${#nums[@]}))
      words+=("${nums[$next]}")
      last=$next
    done
  fi
}

results() {

  declare -i clicksum bh bw 

  clicksum=$((_clicks-_badclicks))

  local key block acc msg

  tput clear
  tput civis
# 093600
  # 37 6  -- 73992
  wpm=$(bc -l <<< "scale=2;($clicksum/$_time)*12")
  acc=$(bc -l <<< "scale=2;(100-($_badclicks/$clicksum)*100)")
  score=$(bc  <<< "(($wpm*$acc)*(1+$_difficulty)/100)")
  score=${score%.*}

  [[ -f $_bookmarkfile ]] && {
    echo "$((_bookmark+_words))" > "$_bookmarkfile"
  }

  

  # unset 'numfiles[@]'
  # wpmr=${wpm%$wpmd}
  # declare -a numfiles
  # for ((i=0;i<${#wpmr};i++)) ; do
  #   fil="$_dir/DOSrebel/${wpmr:$i:1}"
  #   [[ -f $fil ]] && numfiles+=("$fil")
  # done

  # fglt=$(hcat "${numfiles[@]}")

  block=$(
    printf 'WPM:      %6.2f\n' "$wpm"
    printf 'accuracy:%6.1f%% ' "$acc"
    echo -ne "(${_c[f2]}$clicksum${_c[res]}"
    echo -e  "|${_c[f1]}$_badclicks${_c[res]})"
  )

  if ((_time >= 60)); then
    ep=$EPOCHSECONDS
    hs=$(highscore "$wpm" "$score" "$ep")
    grep '\*' <<< "$hs" >/dev/null && \
      msg="A winner is (You)!"$'\n\n'

    poss=$(grep -n "$ep" "$TYPISKT_SCOREFILE")
    msg+="position: ${poss%%:*}"$'\n'
    msg+="score:    ${score}"
  else
    hs=$(highscore)
    msg=$(printf '%s\n' \
      "tests under 60 seconds" \
      "are not added to the"   \
      "scoreboard"             \
    )
  fi

  block+=$'\n\n'"$msg"

  comb=$(paste -d " " <(echo "$hs") - <<< "$block")
  
  # wc -L "always" report 24 characters more...
  declare -i magic=32

  bw=$(wc -L <<< "${comb}")
  bw=$((bw-magic))

  bx=$(( (_width/2) -  ((bw)/2) ))
  
  # don't print highscore in narrow windows
  (( bw > (_width-2) )) && {
    bx=1
    comb="$block"
  }

  bi=$(printf "%${bx}s" " ")
  comb=$(sed "s/^/${bi}/g" <<< "$comb")

  # need separate count because hidden chars
  # bw=$(wc -L <<< "$fglt") 
  # bx=$(( (_width/2) -  (bw/2) ))
  # bi=$(printf "%${bx}s" " ")
  # fglt=$(sed "s/^/${bi}/g" <<< "$fglt")


  comb="$comb"

  bh=$(wc -l <<< "$comb")
  by=$(( (_height/2) - (bh/2) ))

  echo -en "\e[${by};0H${comb}"

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

  _clicks=0  _badclicks=0 _words=0
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
      ((_words++))
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
    --options "d:c:t:w:s:b:lhv" \
    --longoptions "difficulty:,corpus:,time:,width:,seed:,book:,list,help,version," \
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
    --book       | -b ) __o[book]="${2:-}" ; shift ;;
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


