# readme_banner

After seeing [rr-]'s [10ff] program. I thought it would be fun to try to clone the same thing in **bash**. I also had some ideas for features i would like to have in a touchtyping tutor, the thing snowballed into what is now typiskt.

[rr-]:  https://github.com/rr-
[10ff]: https://github.com/rr-/10ff

# readme_footer

[typing_test]: https://github.com/ecly/typing_test
[epbud2txt]: https://github.com/kevinboone/epub2txt2

# readme_install

If you use **Arch Linux** you can get **typiskt** from [AUR](https://aur.archlinux.org/packages/typiskt/).  

**typiskt** have no dependencies and all you need is the `typiskt` script in your PATH. Use the Makefile to do a systemwide installation of both the script and the manpage.  

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
