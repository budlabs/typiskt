#!/bin/bash

listcorpuses() {

  {
    [[ -d "$_dir/wordlists"  ]] && ls "$_dir/wordlists"
    [[ -d "$_sdir/wordlists" ]] && ls "$_sdir/wordlists"
  } | sort -u
  exit
}
