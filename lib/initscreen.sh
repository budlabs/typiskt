initscreen() {

  read -r height width < <(stty size)
  _maxW=$((width<_maxW?width-2:_maxW))

  stty -echo
  tput smcup
  tput civis
  tput clear

  trap cleanup HUP TERM EXIT INT
}
