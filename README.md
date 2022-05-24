# typiskt - terminal touch typing training
After seeing [rr-]'s [10ff] program. I thought it
would be fun to try to clone the same thing
in **bash**. I also had some ideas for features i
would like to have in a touchtyping tutor, the
thing snowballed into what is now typiskt.  

I put a **video** demonstration of **typiskt** on
[youtube]

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

## usage
    typiskt [OPTIONS]
    -b, --book       TEXTFILE | book mode, TEXTFILE used for wordlist
    -c, --corpus     WORDLIST | changes WORDLIST to use in the default (words) mode
    -d, --difficulty INT      | INT == a number 0-10. only avialble in words|book-modes
    -e, --exercise   EXERCISE | exercise from: TYPISKT_CONFIG_DIR/exercises/EXERCISE
    -h, --help                | print help and exit  
    -l, --list                | list available wordlists
    -s, --seed       INT      | use INT as seed for RANDOM
    -u, --source     TEXTFILE | source mode, use TEXTFILE as wordlist
    -t, --time       SECONDS  | set time limit in seconds for the tests
    -v, --version             | print version info and exit  
    -w, --width      WIDTH    | maximum number of characters per line

You get a different type of test depending on
which mode, you start **typiskt** in. No matter
which mode you can press:  
<kbd>Escape</kbd> to restart the test, and  
<kbd>Ctrl</kbd>+<kbd>c</kbd> to quit.

| mode       | words | `--book` | `--source` | `--exercise` |
|:-----------|:------|:---------|:-----------|:-------------|
| Random     | x     |          |            |              |
| Difficulty | x     | x        |            |              |
| Timed      | x     | x        |            |              |
| Bookmark   |       | x        |            |              |
| Line-break |       |          | x          |              |
| Series     |       |          |            | x            |
| Highscore  | x     | x        |            |              |

### words

This is the default mode and it will use words
taken from a corpus and show them in a random
order, the test will stop when the time is up. If
time was more than 60 seconds, the "score" will
get recorded. The default corpus is *english*,
but it can be changed to any corpus listed with
`--list`, using the `--corpus` options. If
`--difficulty` is set, some words will have a
random *wordmask* applied to them making the test
more difficult, difficulty will also add some
bonus point to the high score.

### book

This is very similar to the words mode, except the
words are taken from a specific textfile
(the argument to `--book`) and will be displayed
in chronological order. It will also record the
word the test ended on, so if a new test is
started with the same text, it will resume on
that word (**bookmark**).

### source

Will also print words in chronological order from
a specific file (the argument to `--source`)  but
unlike **book mode** it will respect Line-breaks.
time limit, bookmark and difficulty is disabled
for this mode. It is intended for(short) snippets
of source code. The highest WPM for the file will
be stored and displayed when the test is
completed.

### exercise

The argument to `--exercise` must be the name of a
subdirectory in **TYPISKT_CONFIG_DIR/exercises**.
That subdirectory in turn is expected to contain
one or more wordlists (files with one word/line).
The content of these wordlists will be displayed
in chronological order. And to proceed to the
next exercise/wordlist (sorted in numerical order
with `sort -n`) a certain WPM and accuracy must
be reached (the values can be changed
in **TYPISKT_CONFIG_DIR/config**). You can
navigate between **completed** exercises with the
<kbd>Arrow keys</kbd> in this mode. No exercises
is included with the installation, but the
script:
`TYPISKT_CONFIG_DIR/exercises/add-gtypist-exercises.sh`
will download, convert and install the default
English exercises from [gtypist].




## license

**typiskt** is licensed under **[BSD-2-Clause](LICENSE)**  


[typing_test]: https://github.com/ecly/typing_test
[epbud2txt]: https://github.com/kevinboone/epub2txt2
[youtube]: https://www.youtube.com/watch?v=miRjG-5puz4
[rr-]:  https://github.com/rr-
[10ff]: https://github.com/rr-/10ff
[AUR]: https://aur.archlinux.org/packages/typiskt/
[add-gtypist-exercises.sh]: ./config/add-gtypist-exercises.sh

