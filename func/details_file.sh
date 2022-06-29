#!/bin/bash

details_file() {

mkdir -p "$TYPISKT_CACHE"/details

cat << EOB > "$TYPISKT_CACHE/details/$ep"
WPM=$wpm
key_presses=$clicksum
bad_presses=$_badclicks
accuracy=$acc
difficulty=$dif
score=$score
seconds=$_time
keys=${_details_keys:1}
words=${_details_words:1}
corpus=$_file_words_source
EOB

}
