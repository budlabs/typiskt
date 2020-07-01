#!/bin/bash

sed -r "s|^(installdir\(\) [{] echo \").+(\".*)$|\1${1}\2|" \
  "$2" > "${2}mod"




