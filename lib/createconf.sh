#!/usr/bin/env bash

createconf() {
local trgdir="$1"
declare -a aconfdirs

aconfdirs=(
)

mkdir -p "$1" "${aconfdirs[@]}"

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

# can also be set environment variable TYPISKT_CACHE
# path where to store chache files like highscores
cache-dir = ~/.cache/typiskt

# can also be set environment variable TYPISKT_TIME_FORMAT
# Time format to use in highscore list, see date(1)
# for more format options
highscore-time-format = %y/%m/%d

# in excercise mode minimum must be reached to
# procees to the next exercise. (0=no minimum)
# can also be set environment variable TYPISKT_MIN_ACC
exercise-minimum-accuracy = 96
# can also be set environment variable TYPISKT_MIN_WPM
exercise-minimum-wpm = 0

# syntax:ssHash
EOCONF

}
