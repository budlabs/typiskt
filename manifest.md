---
description: >
  touchtype training for dirt-hackers
updated:       2020-06-26
version:       2020.06.26.71
author:        budRich
repo:          https://github.com/budrich/typiskt
created:       2020-06-08
license:       bsd-2-clause
dependencies:  [bash]
see-also:      [https://github.com/rr-/10ff]
type:          default
environ:
    XDG_CONFIG_HOME: $HOME/.config
    TYPISKT_CONFIG: $XDG_CONFIG_HOME/typiskt/config
    TYPISKT_CACHE: $HOME/.cache/typiskt
    TYPISKT_TIME_FORMAT: "%y/%m/%d"
    TYPISKT_WIDTH: 50
    TYPISKT_WORDLIST: english
    TYPISKT_MIN_ACC: 96
    TYPISKT_MIN_WPM: 0
synopsis: |
    [--corpus|-c WORDLIST] [--difficulty|-d INT] [--time|-t SECONDS] [--width|-w WIDTH] [--seed|-s INT]
    --book|-b TEXTFILE [--difficulty|-d INT] [--time|-t SECONDS] [--width|-w WIDTH]
    --source|-u SOURCECODE [--width|-w WIDTH]
    --exercise|-e DIR|FILE [--width|-w WIDTH]
    --list|-l
    --help|-h
    --version|-v
...

# long_description

https://github.com/rr-/10ff
https://github.com/kevinboone/epub2txt2
length
