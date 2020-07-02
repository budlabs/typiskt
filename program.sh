#!/usr/bin/env bash

___printversion(){
  
cat << 'EOB' >&2
typiskt - version: 2020.07.02.1
updated: 2020-07-02 by budRich
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


main() {

  _source="$(readlink -f "${BASH_SOURCE[0]}")"
  _dir="${_source%/*}"
  _sdir=$(installdir)
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


centerblock() {

  local b indent=""

  b=$(echo -en "$1")
  declare -i bw bh x y

  read -r bh bw _ < <(wc -lL <<< "$b")
  x=$(( bw>_width  ? 0: (_width/2)-(bw/2)  ))
  y=$(( bh>_height ? 0: (_height/2)-(bh/2) ))

  indent=$(printf "%${x}s" " ")
  b="$indent${b//$'\n'/$'\n'${indent}}"

  echo -en "\e[$y;0H$b"

}

trap cleanup HUP TERM EXIT INT

cleanup() {

  # this function gets triggered on both EXIT INT
  # causing it to get triggered twice on ctrl+c
  # therefor testing existence of _tmpE (ERR.sh)
  [[ -f $_tmpE ]] && {

    ((_gotscreen)) && {
      # clear out standard input
      read -rt 0.001 && cat </dev/stdin>/dev/null

      # tput reset
      tput rmcup
      tput cnorm
      stty echo
      tput sgr0
    }
    
    >&2 cat "$_tmpE"
    rm "${_tmpE:?}"
  }
  
  exit 0
}

createconf() {
local trgdir="$1"
declare -a aconfdirs

aconfdirs=(
"$trgdir/exercises"
)

mkdir -p "$1" "${aconfdirs[@]}"

cat << 'EOCONF' > "$trgdir/exercises/add-gtypist-exercises.sh"

trap 'rm "$tmp"' EXIT

_source="$(readlink -f "${BASH_SOURCE[0]}")"
d="${_source%/*}"

url='https://github.com/inaimathi/gtypist-single-space/raw/master/gtypist.typ'
tmp=$(mktemp)

mkdir -p "${tmp%/*}"
wget -qO "$tmp" "$url" || exit

awk -v d=$d '
  match($0,/\s*\*:_(.+)/,ma)   {f=d "/" ma[1]}
  match($0,/^\s*[SD]:(.+)/,ma) {get=1; print ma[1] >> f }
  /^$/ {get=0}
  get == 1 && match($0,/\s*:(.+)/,ma) {print ma[1] >> f }

' "$tmp"

declare -i c

for f in "$d"/* ; do
  [[ ${f##*/} =~ ([^C])_R_L([0-9]+) ]] && {
    name=${BASH_REMATCH[1]}
    num=${BASH_REMATCH[2]}
    mkdir -p "$d/$name"
    tf=$d/$name/$num
    awk -v f=$tf '{for (i=1;i<=NF;i++) {print $i >> f}}' "$f"
    rm "$f"
  }

  [[ ${f##*/} =~ C_R_.+ ]] && {
    name=C
    num=$((c++))
    mkdir -p "$d/$name"
    tf=$d/$name/$num
    awk -v f=$tf '{for (i=1;i<=NF;i++) {print $i >> f}}' "$f"
    rm "$f"
  }
done
EOCONF

chmod +x "$trgdir/exercises/add-gtypist-exercises.sh"
cat << 'EOCONF' > "$trgdir/exercises/README.md"
when **typiskt** is executed with the `--exercise ARG` option, it will look in this directory for a sub directory with the same name as ARG. **typiskt** doesn't come with any exercises, but executing the script: `add-gtypist-exercises.sh` will download and convert the default English exercises from <https://github.com/inaimathi/gtypist-single-space>, and add them to this directory.
EOCONF

cat << 'EOCONF' > "$trgdir/config"
# can also be set with --corpus commandlineoption
# or environment variable TYPISKT_WORDLIST
# list wordlists with --list commandlineoption
default-wordlist = english-advanced

# can also be set with --width commandlineoption
# or environment variable TYPISKT_WIDTH
# maximum width (in columns) of lines
# if max-width > COLUMNS-2, max-width=COLUMNS-2
maxwidth = 50

# can also be set with environment variable TYPISKT_CACHE
# path where to store chache files like highscores
cache-dir = ~/.cache/typiskt

# can also be set with environment variable TYPISKT_TIME_FORMAT
# Time format to use in highscore list, see date(1)
# for more format options
highscore-time-format = %y/%m/%d

# in excercise mode minimum must be reached to
# proceed to the next exercise. (0=no minimum)
# can also be set with environment variable TYPISKT_MIN_ACC
exercise-minimum-accuracy = 96
# can also be set with environment variable TYPISKT_MIN_WPM
exercise-minimum-wpm = 0

# syntax:ssHash
EOCONF

}

set -E
trap '[ "$?" -ne 77 ] || exit 77' ERR

_tmpE=$(mktemp)

ERX() { echo  "[ERROR] $*" > "$_tmpE" ; exit 77 ;}
ERR() { echo  "[WARNING] $*" > "$_tmpE"  ;}
ERM() { echo  "$*" > "$_tmpE"  ;}
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

initscreen() {

  stty -echo
  tput smcup
  tput civis

  resize

  _gotscreen=1

  # TODO: resize trap gets triggered on first keypress...
  # trap resize SIGWINCH

}

resize() {

  tput clear
  read -r _height _width < <(stty size)

  : "${_maxW:=${__o[width]:-$TYPISKT_WIDTH}}"
  _maxW=$(( (_width-2)<_maxW?_width-2:_maxW ))

  pos[pY]=$(( (_height/2) - 2))
  pos[aY]=$(( pos[pY]+3 ))
  pos[aX]=$(( (_width/2) - (_maxW/2) ))
  pos[tY]=$(( pos[aY]+3 ))
  pos[tX]=$(( (_width/2) - (5/2) ))
  pos[fY]=$(( pos[pY]+1 ))
  pos[fX]=$(( (_width/2) - (_underlinewidth/2) ))
  pos[pX]=$(( pos[fX]+1 ))

  local f
  f=$(printf "%${_underlinewidth}s" " ")  f=${f// /─}
  _underline="\e[${pos[fY]};${pos[fX]}H$f"

  ((pos[aX])) && _activeindent="$(printf "%${pos[aX]}s" " ")"
  blank=$(printf "%${_width}s" " ")
  _resize=1
}

installdir() { echo "$_dir" ;}

listcorpuses() {

  {
    [[ -d "$_dir/wordlists"  ]] && ls "$_dir/wordlists"
    [[ -d "$_sdir/wordlists" ]] && ls "$_sdir/wordlists"
  } | sort -u
  exit
}

makelist() {

  local list exd exf tmpf exh corpus
  tmpf=$(mktemp)

  case "$_mode" in

   ( words )
     corpus=${__o[corpus]:-$TYPISKT_WORDLIST}

     [[ -f "${list:=$_dir/wordlists/$corpus}"  ]] || unset list
     [[ -f "${list:=$_sdir/wordlists/$corpus}" ]] || unset list
     : "${list:=$corpus}"

    ;;

    ( book )
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

      [[ -d ${exd:=${TYPISKT_CONFIG_DIR}/exercises/${__o[exercise]}} ]] \
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
  # cat "$tmpf" > /home/bud/git/bud/src/new/typisktstart/op
  rm "$tmpf"
}

nextword() {

  ((_activepos == _lastpos)) && setline

  _activeword=${activeline[$_nextpos]}
  _activelength=${#_activeword}
  _activepos=$_nextpos
  _nextpos=$(( _activepos+(_activelength+1) ))
  setstatus 3

  _string=""

  # reset prompt
  op+="\e[${pos[pY]};0H${blank}\e[${pos[pY]};${pos[pX]}H"

}

parseconfig() {
  
  local line re sp ns k v

  [[ -f $TYPISKT_CONFIG_DIR/config ]] \
    || createconf "$TYPISKT_CONFIG_DIR"

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
    esac

  } ; done < "$TYPISKT_CONFIG_DIR/config"
}

randomize() {

  local last next
  declare -i t n

  # 9*time ~ 500wpm
  n=$((_time*9))
  unset 'words[@]'

  if ((_prop & m[random])); then

    for ((i=0; i<n; i++)); do
      next=$((RANDOM%${#wordlist[@]}))
      ((next == last)) && next=$((RANDOM%${#wordlist[@]}))
      words+=("$next")
      last=$next
    done

  elif ((_prop & m[bookmark])); then

    [[ -f $_bookmarkfile ]] && _bookmark=$(< "$_bookmarkfile")

    t=$((${#wordlist[@]}-1))
    g=$((t-_bookmark))

    ERM "g=$g t=$t n=$n"

    ((g<n)) && while ((${#words[@]}<n)); do
      if ((t<n)); then
        eval "words+=({$t..0})"
      else
        eval "words+=({$n..0})"
      fi
    done

    eval "words+=({$t..$_bookmark})"
    # n=$((t-_bookmark))
    
  else
    t=$((${#wordlist[@]}-1))
    
    eval "words=({$t..0})"
  fi
}

results() {

  declare -i clicksum bh bw nextex time bm

  time=$((_time?_time:SECONDS-_start))
  clicksum=$((_clicks-_badclicks>1?_clicks-_badclicks:1))

  local key wpm block acc msg=""

  tput civis

  acc=$(bc -l <<< "scale=3;(100-($_badclicks/$clicksum)*100)")
  wpm=$(bc -l <<< "scale=2;($clicksum/$time)*12")
  [[ ${acc:0:1} = - ]] && acc=0.0
  
  [[ -f $_bookmarkfile ]] && {
    bm=$(( (_bookmark+_words)-1))
    while ((bm > ${#wordlist[@]}-1 )); do ((bm-=${#wordlist[@]} )) ; done
    echo "$bm" > "$_bookmarkfile"
  }

  case "$_mode" in

    ( source )
      declare filename=${__o[source]##*/}
      msg+="$filename containing ${_words} words\n"
      msg+="was typed in $time seconds\n\n"
      msg+="with an average WPM of ${wpm}\n"
      msg+="${acc:0:-2}% accurate."

      msg+="\n\n"

      local lwpm=0.0
      local flwpm=$TYPISKT_CACHE/$_listhash

      [[ -f $flwpm ]] && lwpm=$(< "$TYPISKT_CACHE/$_listhash")
      if (( ${wpm/./} < ${lwpm/./} )); then
        msg+="highest WPM on this file: ${lwpm}"
      else
        msg+="this is your best result"
        echo "$wpm" > "$flwpm"
      fi

      tput clear
      msg=$(centerblock "$msg")
    ;;

    ( exercise )

      declare -i apass wpass

      apass=$((!TYPISKT_MIN_ACC || ${acc%.*} > TYPISKT_MIN_ACC ))
      wpass=$((!TYPISKT_MIN_WPM || ${wpm%.*} > TYPISKT_MIN_WPM ))
      
      ((apass && wpass)) && {
        nextex=$((_lastexercise+1<${#exercises[@]}
                 ?_lastexercise+1:0))
        
        echo "$nextex" > "$_exercisefile"
        echo "$wpm" > "$TYPISKT_CACHE/$_listhash"
      }

      msg=" accuracy: "
      ((apass)) && msg+="${_c[f2]}" || msg+="${_c[f1]}"
      msg+="${acc:0:-2}%${_c[res]}"

      msg+=" | WPM: "
      ((wpass)) && msg+="${_c[f2]}" || msg+="${_c[f1]}"
      msg+="$wpm${_c[res]}"

      msg+="\n press escape "
      ((apass && wpass)) \
        && msg+="for next exercise"   \
        || msg+="to restart exercise"

      msg="\e[$((_height-1));0H$msg"
      
      makelist
    ;;

    ( words|book )

      tput clear

      declare -i dif
      dif=${__o[difficulty]:-0}
      score=$(bc <<< "scale=2;100*((($wpm*$acc)/100)+1+$dif)")
      score=${score%.*}

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

        poss=$(grep -n "$ep" "$TYPISKT_CACHE/scorefile")
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

      # don't print highscore in narrow windows
      (( bw > (_width-2) )) && comb="$block"

      msg=$(centerblock "$comb")
    ;;

  esac

  echo -en "$msg"

  while :; do
    IFS= read -rsn1 key || continue

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

  unset 'activeline[@]'
  for k in "${!nextline[@]}"; do
    activeline[$k]=${nextline[$k]}
    _lastpos=$k
  done

  _nextpos=0
  makeline

  op+="\e[${pos[aY]};0H$blank\n${blank}\e[${pos[aY]};0H"
  op+="$_activeindent${activeline[*]}\n"
  op+="$_activeindent${nextline[*]}"

}

makeline() {

  # creates new nextline array
  # add words to array, as long as they fit in _maxW

  declare -i ll wl j
  local w

  unset 'nextline[@]'

  while ((${#words[@]})); do
    wln=${words[-1]}
    w=${wordlist[${words[-1]}]}

    ((_difficulty)) && {

      j=$((RANDOM%_difficulty ))
      if [[ -n ${wordmasks[$j]} ]]; then
        w=${wordmasks[$j]/W/$w}
      elif ((j == (${#wordmasks[@]}+1) )); then
        w="$((RANDOM%1111111))"
      elif ((j == (${#wordmasks[@]}+2) )); then
        w=budlabs
      elif ((j == (${#wordmasks[@]}+3) )); then
        w="${w^}"
      elif ((j == (${#wordmasks[@]}+4) )); then
        w="${w^^}"
      fi

    }

    [[ $w = "@@EOL" ]] && {
      unset 'words[-1]'
      unset "wordlist[$wln]"
      break
    }

    wl=${#w}

    (( (ll+=(wl+1)) < _maxW || _prop & m[linebreak])) || break

    # index in array is also xposition
    nextline+=([$((ll-(wl+1)))]="$w")

    unset 'words[-1]'

  done

}

setstatus() {

  # changes color of "_activeword"
  # 1=red, 2=green, 3=yellow

  local style status=$1

  op+="${_c[civis]}${_c[sc]}"
  style="${_c[f$status]}${_activeword}${_c[res]}"
  op+="\e[${pos[aY]};$((_activepos+1+pos[aX]))H${style}"
  # op+="\e[${pos[pY]};$((pos[pX]+${#_string}))H"
  op+="${_c[cnorm]}${_c[rc]}"

  _oldstatus=$status
}

starttest() {

  local key c1 c2 exd
  declare -i lasttime=-1 status sl cl

  _clicks=0  _badclicks=0 _words=0 _start=0 _activepos=-1 _resize=0
  _string=""

  op=$_underline

  [[ -n ${exd:=${__o[exercise]}} ]] && ((pos[pY]>1)) && {

    op+="\e[1;1Hexercise ${exd##*/} "
    op+="($((_lastexercise+1))/${#exercises[@]}) "

    local lwpm # last wpm on current exercise
    [[ -f ${lwpm:=$TYPISKT_CACHE/$_listhash} ]] && {
      lwpm=$( < "$lwpm" )
      lwpm=${lwpm:0:-1}
      op+="best WPM: $lwpm"
      :
    } || op+="               "

    op+="    "
  }
  
  # when linebreaks are used, a new list have to be
  # generated each game
  ((_prop & m[linebreak])) && makelist

  randomize
  makeline
  setline
  nextword
  ((_time)) && timer
  
  until ((_resize)) ; do
    
    ((_start && SECONDS>_t && _time)) && break
    ((_time || ${#wordlist[@]}!=_words)) || break

    # update screen
    [[ -n $op ]] && { echo -en "$op" ; op="" ;}

    ((_start && SECONDS != lasttime && _time)) && timer
    
    # https://stackoverflow.com/a/46481173
    IFS= read -rsn1 key || continue

    # any graphical character
    if [[ $key =~ [[:graph:]] ]]; then
      _string+=$key

      # start the timer
      ((_start)) || { _start=$SECONDS ; _t=$((_time+_start)) ;}

      nextchar=${_activeword:$((${#_string}-1)):1}
      [[ $key = "$nextchar" ]] && status=$_oldstatus \
                               || status=1
      
      ((++_clicks && status == 1 && _badclicks++))

    # space, submit word (empty $key == Enter)
    elif [[ $key = " " || -z $key ]]; then
      (( _words++ + _clicks++ ))
      ((_oldstatus != 2 && ++_badclicks)) && {
        
        ((_oldstatus == 1 || _activepos == _lastpos)) \
          || setstatus 1

        sl=${#_string}
        cl=$((sl>_activelength?sl:_activelength))
        for ((i=0;i<cl;i++)); do
          c1=${_string:$i:1} c2=${_activeword:$i:1}
          [[ $c1 = "$c2" ]] || ((_badclicks++))
        done
      }
      nextword
      continue
    # https://askubuntu.com/a/299469
    # backspace key
    elif [[ $key = $'\177' ]]; then
      ((${#_string}<1 && ++_badclicks)) && continue
      key=$'\b \b'
      _string=${_string:0:-1}

      [[ $_string = "${_activeword:0:${#_string}}" ]] \
        && status=3 || status=1

      # penalty for erasing good char
      ((_oldstatus == 1 || _badclicks++)) 

    # escape sequence
    elif [[ $key = $'\u1b' ]]; then
      # catch arrowkeys etc
      read -rsn2 -t 0.001 key && {
        # shift exercise
        [[ $_mode = exercise ]] || continue
        case "$key" in
          '[D'|'[A' )  # left/up
            nextex=$((_lastexercise-1<0
                     ?${#exercises[@]}-1:_lastexercise-1))
          ;;
          '[B'|'[C' )  # down/right
            cheating="${_exercisefile%/*}/$_listhash"
            if [[ -f $cheating ]]; then
              nextex=$((_lastexercise+1<${#exercises[@]}
                       ?_lastexercise+1:0))
            else
              echo -en "${_c[civis]}${_c[sc]}\e[$_height;0H${_c[f1]}NO CHEATING${_c[res]}"
              read -rsn 1
              echo -en "\e[$_height;0H$blank${_c[rc]}${_c[norm]}"
              continue
            fi
          ;;
          * ) continue ;;
        esac

        echo "$nextex" > "$_exercisefile"
        makelist
        return
      }

      # pressing escape alone will restart the game
      return  
    else
      continue
    fi

    [[ $_activeword = "$_string" ]] && status=2

    ((status == _oldstatus)) || setstatus $status
    op+="$key"

  done

  ((_resize)) || _restart=0
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

wordsfromfile() {
  local f=$1

  declare -i lb=0
  ((_prop & m[linebreak])) && lb=1

  awk -v lb=$lb '
  /./ {
    for (i=1;i<=NF;i++) {
      word=$i
      print word
    }
    if (lb==1) print "@@EOL"
  }
  ' "$f"
}


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


main "${@}"


