#!/bin/bash

nextword() {

  ((_activepos == _lastpos)) && setline

  _activeword=${activeline[$_nextpos]}
  _activelength=${#_activeword}
  _activepos=$_nextpos
  _nextpos=$(( _activepos+(_activelength+1) ))
  setstatus "$_statusactive"

  _string=""

  # reset prompt
  op+="\e[${pos[pY]};0H${blank}\e[${pos[pY]};${pos[pX]}H"

}
