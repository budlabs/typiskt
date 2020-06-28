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

`--difficulty`|`-d` INT  

`--time`|`-t` SECONDS  

`--width`|`-w` WIDTH  

`--seed`|`-s` INT  

`--book`|`-b` TEXTFILE  

`--source`|`-u` TEXTFILE  

`--exercise`|`-e` EXERCISE  

`--list`|`-l`  

`--help`|`-h`  
Show help and exit.

`--version`|`-v`  
Show version and exit.

## license

**typiskt** is licensed with the **BSD-2-CLAUSE license**


