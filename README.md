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

usage
-----

| mode     |Random|Difficulty|Timed|Bookmark|Line-break|Loop|Series|Highscore|
|:---------|:----:|:--------:|:---:|:------:|:--------:|:--:|:----:|:-------:| 
| words    |x     |x         |x    |        |          |    |      |x        | 
| book     |      |x         |x    |x       |          |x   |      |x        | 
| source   |      |          |     |        |x         |    |      |         | 
| exercise |      |          |     |        |          |    |x     |         | 

https://github.com/kevinboone/epub2txt2 length


options
-------

```text
typiskt [--corpus|-c WORDLIST] [--difficulty|-d INT] [--time|-t SECONDS] [--width|-w WIDTH] [--seed|-s INT]
typiskt --book|-b TEXTFILE [--difficulty|-d INT] [--time|-t SECONDS] [--width|-w WIDTH]
typiskt --source|-u SOURCECODE [--width|-w WIDTH]
typiskt --exercise|-e DIR [--width|-w WIDTH]
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

`--source`|`-u` SOURCECODE  

`--exercise`|`-e` DIR  

`--list`|`-l`  

`--help`|`-h`  
Show help and exit.

`--version`|`-v`  
Show version and exit.

## license

**typiskt** is licensed with the **BSD-2-CLAUSE license**


