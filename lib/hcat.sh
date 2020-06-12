#!/bin/bash

hcat() {

  while getopts :s: o ; do 
    [[ -n $o ]] && spacing=${OPTARG} ; shift 2
  done

  awk -v spacing="${spacing:-1}" '

    BEGIN { id=0 }

    FNR == 1 && FNR != NR {

      lengths[id]+=spacing
      space=sprintf("%"lengths[id]"s"," ")
      last = id ; id++

      for (line in files[last]) {
        files[id][line] = files[last][line] space
      }

    }

    lengths[id] < length(gensub(/[^[:print:]]/,"","g",$0)) {
      lengths[id]=length(gensub(/[^[:print:]]/,"","g",$0))
    }
    id != 0 {
      if (FNR in files[last])
        r=sprintf("%-"lengths[last]"s",files[last][FNR])
      else
        r = space
      sub(/^/,r)
    }
    {files[id][FNR] = $0}

    END {
      for (line in files[id]) {
        print files[id][line]
      }
    }

  ' "$@"
}
