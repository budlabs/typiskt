#!/bin/bash

# this is a helperscrip that is executed from the
# makefile. it looks for this line:
# installdir() { echo "$_dir" ;}
# in $2 (the main script)
# and replaces $_dir with $1 (the systemwide conf dir)

sed -r "s|^(installdir\(\) [{] echo \").+(\".*)$|\1${1}\2|" \
  "$2" > "${2}mod"




