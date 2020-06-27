`typiskt` - touchtype training for dirt-hackers

SYNOPSIS
--------
```text
typiskt [--corpus|-c WORDLIST] [--difficulty|-d INT] [--time|-t SECONDS] [--width|-w WIDTH] [--seed|-s INT]
typiskt --book|-b TEXTFILE [--difficulty|-d INT] [--time|-t SECONDS] [--width|-w WIDTH]
typiskt --source|-u SOURCECODE [--width|-w WIDTH]
typiskt --exercise|-e DIR [--width|-w WIDTH]
typiskt --list|-l
typiskt --help|-h
typiskt --version|-v
```

DESCRIPTION
-----------
https://github.com/rr-/10ff
https://github.com/kevinboone/epub2txt2 length


OPTIONS
-------

`--corpus`|`-c` WORDLIST  

`--difficulty`|`-d` INT  

`--time`|`-t` SECONDS  

`--width`|`-w` WIDTH  

`--seed`|`-s` INT  

`--book`|`-b` TEXTFILE  

`--source`|`-u` SOURCECODE  

`--exercise`|`-e` DIR  

`--list`|`-l`  

`--help`|`-h`  
Show help and exit.

`--version`|`-v`  
Show version and exit.


ENVIRONMENT
-----------

`XDG_CONFIG_HOME`  

defaults to: $HOME/.config

`TYPISKT_CONFIG`  

defaults to: $XDG_CONFIG_HOME/typiskt/config

`TYPISKT_CACHE`  

defaults to: $HOME/.cache/typiskt

`TYPISKT_TIME_FORMAT`  

defaults to: "%y/%m/%d"

`TYPISKT_WIDTH`  

defaults to: 50

`TYPISKT_WORDLIST`  

defaults to: english

`TYPISKT_MIN_ACC`  

defaults to: 96

`TYPISKT_MIN_WPM`  

defaults to: 0

DEPENDENCIES
------------
`bash`



