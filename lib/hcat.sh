#!/bin/bash

hcat() {
  awk '

    BEGIN { id=0 }

    FNR == 1 && FNR != NR {

      lengths[id]+=lengths[last]+1
      space=sprintf("%"lengths[id]"s"," ")
      last = id ; id++

      for (line in files[last]) {
        files[id][line] = files[last][line] space
      }

    }

    lengths[id] < length() {lengths[id]=length()}
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
