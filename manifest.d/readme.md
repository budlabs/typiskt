# readme_banner

After seeing [rr-]'s [10ff] program. I thought it would be fun to try to clone the same thing in **bash**. I also had some ideas for features i would like to have in a touchtyping tutor, the thing snowballed into what is now typiskt.  

I put a **video** demonstration of **typiskt** on [youtube](https://www.youtube.com/watch?v=miRjG-5puz4)

[rr-]:  https://github.com/rr-
[10ff]: https://github.com/rr-/10ff

# readme_footer

[typing_test]: https://github.com/ecly/typing_test
[epbud2txt]: https://github.com/kevinboone/epub2txt2

# readme_install

If you use **Arch Linux** you can get **typiskt** from [AUR](https://aur.archlinux.org/packages/typiskt/).  

**typiskt** is a **bash** script and the only *external* commands used are:  

- bc - to calculate WPM and accuracy
- gawk - to create wordlists in `--book` and `--source` mode
- paste - for vertical concatenation of results/highscore
- wc - get size of text blocks before centering them
- tput (ncurses) - get escape codes
- getopt - long-option support  
- curl - only used in [add-gtypist-exercises.sh](./config/add-gtypist-exercises.sh) 
- md5sum - used for various caching functions.
- date - to display highscore table  

If these commands are not installed they should be available in most distributions official package repositories, but you probably already have them.  

Use the Makefile to do a systemwide installation of both the script and the manpage.  

(*configure the installation destination in the Makefile, if needed*)

```
$ git clone https://github.com/budlabs/typiskt.git
$ cd typiskt
# make install
$ typiskt -v
typiskt - version: 2020.06.22.1
updated: 2020-06-22 by budRich
```

when **typiskt** is executed and **TYPISKT_CONFIG_DIR** (defaults to `~/.config/typiskt`) or **TYPISKT_CACHE** (defaults to `~/.cache/typiskt`) doesn't exist, they will get created.
