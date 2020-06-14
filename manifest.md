---
description: >
  touchtype training for dirt-hackers
updated:       2020-06-14
version:       2020.06.14.0
author:        budRich
repo:          https://github.com/budrich/typiskt
created:       2020-06-08
license:       bsd-2-clause
dependencies:  [bash]
see-also:      [https://github.com/rr-/10ff]
type:          default
environ:
    XDG_CONFIG_HOME: $HOME/.config
    TYPISKT_CACHE: $HOME/.cache/typiskt
    TYPISKT_TIME_FORMAT: "%y/%m/%d"
synopsis: |
    [--corpus|-c WORDLIST] [--difficulty|-d INT] [--time|-t SECONDS] [--width|-w WIDTH] [--seed|-s INT]
    [--book|-b BOOKWORDLIST] [--difficulty|-d INT] [--time|-t SECONDS] [--width|-w WIDTH]
    [--source|-u SOURCECODE] [--time|-t SECONDS] [--width|-w WIDTH]
    --list|-l
    --help|-h
    --version|-v
...

# long_description

https://github.com/rr-/10ff
https://github.com/kevinboone/epub2txt2
length

### DOS Rebel

The files in `./DOSrebel` are the integer glyphs from the `figlet(1)` font
"DOS Rebel" by Valerie Mates, based on a font by Ron Bliss
(who sometimes goes by the name "rebel" because his initials are REB).  

I didn't want to add 'figlet' and/or the font as dependencies, instead there is a simple `hcat()` (*horizontal concatenation*) function included that emulates figlets good enough for printer numbers.
