#!/usr/bin/env bash

createconf() {
local trgdir="$1"
declare -a aconfdirs

aconfdirs=(
"$trgdir/exercises"
)

mkdir -p "$1" "${aconfdirs[@]}"

cat << 'EOCONF' > "$trgdir/exercises/add-gtypist-exercises.sh"
#!/bin/bash

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
