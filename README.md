# typiskt - touchtype training for dirt-hackers 

After seeing [rr-]'s [10ff] program. I thought it would be
fun to try to clone the same thing in **bash**. I also had
some ideas for features i would like to have in a
touchtyping tutor, the thing snowballed into what is now
typiskt.

[rr-]:  https://github.com/rr-
[10ff]: https://github.com/rr-/10ff



## installation

If you use **Arch Linux** you can get **typiskt** from
[AUR](https://aur.archlinux.org/packages/typiskt/).  

**typiskt** have no dependencies and all you need is the
`typiskt` script in your PATH. Use the Makefile to do a
systemwide installation of both the script and the manpage.  

(*configure the installation destination in the Makefile,
if needed*)

```
$ git clone https://github.com/budlabs/typiskt.git
$ cd typiskt
# make install
$ typiskt -v
typiskt - version: 2020.06.22.1
updated: 2020-06-22 by budRich
```


when **typiskt** is executed and **TYPISKT_CONFIG_DIR** (defaults to `~/.config/typiskt`) or **TYPISKT_CACHE** (defaults to `~/.cache/typiskt`) doesn't exist, they will get created.

usage
-----

You will get a different type of test depending on which
mode you start **typiskt** in. No matter which mode you can
press <kbd>Escape</kbd> to restart the test, and
<kbd>Ctrl</kbd>+<kbd>c</kbd> to quit.


| mode     |Random|Difficulty|Timed|Bookmark|Line-break|Series|Highscore|
|:---------|:----:|:--------:|:---:|:------:|:--------:|:----:|:-------:| 
| words    |x     |x         |x    |        |          |      |x        | 
| book     |      |x         |x    |x       |          |      |x        | 
| source   |      |          |     |        |x         |      |         | 
| exercise |      |          |     |        |          |x     |         |

### words


This is the default mode and it will use words taken from a
corpus and show them in a random order, the test will stop
when the time is up. If time was more then 60 seconds, the
"score" will get recorded. The default corpus is *english*,
but it can be changed to any corpus listed with `--list`,
using the `--corpus` options. If `--difficulty` is set, some
words will have a random *wordmask* applied to them making
the test more difficult, difficulty will also add some bonus
point to the high score.

### book


This is very similar to the words mode, except the words
are taken from a specific textfile (the argument to
`--book`) and will be displayed in chronological order. It
will also record the word the test ended on, so if a new
test is started with the same text, it will resume on that
word (**bookmark**).

### source


Will also print words in chronological order from a
specific file (the argument to `--source`)  but unlike
**book mode** it will respect Line-breaks. time limit,
bookmark and difficulty is disabled for this mode. It is
intended for (short) snippets of source code. The highest
WPM for the file will be stored and displayed when the test
is completed.

### exercise


The argument to `--exercise` must be the name of a subdirectory in **TYPISKT_CONFIG_DIR/exercises**. That subdirectory in turn is expected to contain one or more wordlists (files with one word/line). The content of these wordlists will be displayed in chronological order. And to proceed to the next exercise/wordlist (sorted in numerical order with `sort -n`) a certain WPM and accuracy must be reached (the values can be changed in **TYPISKT_CONFIG_DIR/config**). You can navigate between **completed** exercises with the <kbd>Arrow keys</kbd> in this mode. No exercises is included with the installation, but the script: `TYPISKT_CONFIG_DIR/exercises/add-gtypist-exercises.sh` will download, convert and install the default English exercises from [gtypist].


options
-------

```text
typiskt [--corpus|-c WORDLIST] [--difficulty|-d INT] [--time|-t SECONDS] [--width|-w WIDTH] [--seed|-s INT]
typiskt --book|-b TEXTFILE [--difficulty|-d INT] [--time|-t SECONDS] [--width|-w WIDTH]
typiskt --source|-u TEXTFILE [--width|-w WIDTH]
typiskt --exercise|-e EXERCISE [--width|-w WIDTH]
typiskt --list|-l
typiskt --help|-h
typiskt --version|-v
```


`--corpus`|`-c` WORDLIST  
changes WORDLIST to use in the default (**words**) mode.
Defaults to *english*. This value can also be set in
`TYPISKT_CONFIG_DIR/config` or with the environment variable
**TYPISKT_WORDLIST**.

`--difficulty`|`-d` INT  
INT must be a number 0-10, the higher the difficulty the
more often a wordmask will be applied to words in modes that
supports `--difficulty` (words|book).

`--time`|`-t` SECONDS  
Number of seconds a test will last in modes that supports
`--time` (words|book). Defaults to 60.

`--width`|`-w` WIDTH  
Maximum width in columns for lines. Defaults to:
`min(50,COLUMNS-2)`

`--seed`|`-s` INT  
Seed to be used for RANDOM. Defaults to `$(od -An -N3 -i
/dev/random)`

`--book`|`-b` TEXTFILE  
Sets mode to **book** and uses TEXTFILE as a wordlist.

`--source`|`-u` TEXTFILE  
Sets mode to **source** and uses TEXTFILE as a wordlist.

`--exercise`|`-e` EXERCISE  
Sets mode to **exercise** and looks in
**TYPISKT_CONFIG_DIR/exercises/EXERCISE** for files to
generate wordlists.

`--list`|`-l`  
List available wordlists in **WORDLIST_DIR** (defaults to
`/usr/share/typiskt/wordlist` or `SCRIPTDIR/wordlists`).

`--help`|`-h`  
Show help and exit.

`--version`|`-v`  
Show version and exit.

## updates

### 2020.07.01
initial release


[typing_test]: https://github.com/ecly/typing_test
[epbud2txt]: https://github.com/kevinboone/epub2txt2



## license

**typiskt** is licensed with the **BSD-2-CLAUSE license**


