#!/usr/bin/env bash

main() {

  _source="$(readlink -f "${BASH_SOURCE[0]}")"
  _dir="${_source%/*}"
  _sdir=/usr/share/typiskt
  _bookmarkfile=""
  _exercisefile=""
  _underline=""
  _listhash=""
  _activeindent=""

  ((__o[list])) && listcorpuses

  declare -i _height _width _maxW _difficulty
  declare -i _activepos _nextpos _lastpos
  declare -i _time _t _oldstatus _bookmark
  declare -i _restart=1 _clicks=0 _badclicks=0
  declare -i _seed _lastexercise _start _gotscreen=0
  declare -i _underlinewidth=14 _resize=0 

  declare -a exercises
  declare -a wordlist   # wordlist as array
  declare -a words      # ${wordlist[${words[-1]}]}=next
  declare -a wordmasks  # specialsfile as array
  declare -a nextline activeline

  declare -A pos
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

  : "${_seed:=${__o[seed]:-$(od -An -N3 -i /dev/random)}}"
  RANDOM=$_seed

  declare -A m # mask array
  masks=(random difficulty time bookmark linebreak loop)
  for ((i=0;i<${#masks[@]};i++)); do 
    m[${masks[$i]}]=$((1<<i))
  done ; unset 'masks[@]'

  _mode=words
  [[ -n ${__o[exercise]}  ]] && _mode=exercise
  [[ -n ${__o[source]}    ]] && _mode=source
  [[ -n ${__o[book]}      ]] && _mode=book

  declare -i _prop # mode prpoperties
  case "$_mode" in
    words     ) _prop=$((m[random] | m[difficulty] | m[time] | m[loop])) ;;
    source    ) _prop=$((m[linebreak])) ;;
    exercise  ) _prop=$((0)) ;;
    book      ) _prop=$((m[difficulty] | m[time] | m[bookmark] | m[loop])) ;;
  esac

  parseconfig

  [[ -d $TYPISKT_CACHE ]] || mkdir -p "$TYPISKT_CACHE"

  makelist

  ((_prop & m[bookmark])) && {
    _bookmarkfile="$TYPISKT_CACHE/$_listhash"
    [[ -f $_bookmarkfile ]] || {
      echo 0 > "$_bookmarkfile"
    }
  }

  : "${_time:=${__o[time]:-60}}"
  ((_prop & m[time])) || _time=0
  
  ((_prop & m[difficulty])) && {

    _difficulty=$(( __o[difficulty] < 1  ? 0 : 
                    __o[difficulty] < 11 ? __o[difficulty] :
                    __o[difficulty] > 10 ? 10 : 0 ))

    local maskfile
    
    [[ -f "${maskfile:=$_dir/wordmasks}"  ]] || unset maskfile
    [[ -f "${maskfile:=$_sdir/wordmasks}" ]] || _difficulty=0
    
    ((_difficulty)) && {
      mapfile -t wordmasks < "$maskfile"
      _difficulty=$(( ${#wordmasks[@]} * ((11-_difficulty) +4) ))
    }

  }

  initscreen

  while ((_restart)); do
    while ((_restart)); do starttest ; done
    results
  done

}

___source="$(readlink -f "${BASH_SOURCE[0]}")"  #bashbud
___dir="${___source%/*}"                        #bashbud
source "$___dir/init.sh"                        #bashbud
main "${@}"                                     #bashbud
