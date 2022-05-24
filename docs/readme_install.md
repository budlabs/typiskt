## installation

If you use **Arch Linux** you can get **typiskt**
from [AUR]. 

**typiskt** is a **bash** script and the
  only *external* commands used are:  

- bc - to calculate WPM and accuracy
- gawk - to create wordlists in `--book` and `--source` mode
- paste - for vertical concatenation of results/highscore
- wc - get size of text blocks before centering them
- tput (ncurses) - get escape codes
- getopt - long-option support  
- curl - only used in [add-gtypist-exercises.sh]
- md5sum - used for various caching functions.
- date - to display highscore table  

If these commands are not installed they should be
available in most distributions official package
repositories, but you probably already have
them. 

Use the Makefile to do a systemwide installation
of both the script and the manpage.  

Build dependencies are\*: **gawk**, GNU make, and bash

(*configure the installation destination in the Makefile, if needed*)  
\* *to re-build the manpage `go-md2man` is needed*

```
$ git clone https://github.com/budlabs/typiskt.git
$ cd typiskt
$ make
# make install
$ typiskt -v
typiskt - version: 2020.06.22.1
updated: 2020-06-22 by budRich
```

