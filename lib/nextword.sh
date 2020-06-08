nextword() {
  ((activepos == lastpos)) && setline

  activeword=${activeline[$nextpos]}
  activelegnth=${#activeword}
  activepos=$nextpos
  nextpos=$(( activepos+(activelegnth+1) ))
  setstatus 3

  prompt=""
  string=""
  echo -en "$op\e[${pos[pY]};0H${blank}\e[${pos[pY]};${pos[pX]}H"

}
