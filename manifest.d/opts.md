# options-help-description
Show help and exit.

# options-version-description
Show version and exit.

# options-corpus-description
changes WORDLIST to use in the default (**words**) mode. Defaults to *english*.
This value can also be set in `TYPISKT_CONFIG_DIR/config` or with the environment variable **TYPISKT_WORDLIST**.

# options-difficulty-description
INT must be a number 0-10, the higher the difficulty the more often a wordmask will be applied to words in modes that supports `--difficulty` (words|book).

# options-time-description
Number of seconds a test will last in modes that supports `--time` (words|book). Defaults to 60.

# options-width-description
Maximum width in columns for lines. Defaults to: `min(50,COLUMNS-2)`

# options-seed-description
Seed to be used for RANDOM. Defaults to `$(od -An -N3 -i /dev/random)`

# options-book-description
Sets mode to **book** and uses TEXTFILE as a wordlist.

# options-source-description
Sets mode to **source** and uses TEXTFILE as a wordlist.

# options-exercise-description
Sets mode to **exercise** and looks in **TYPISKT_CONFIG_DIR/exercises/EXERCISE** for files to generate wordlists.

# options-list-description
List available wordlists in **WORDLIST_DIR** (defaults to `/usr/share/typiskt/wordlist` or `SCRIPTDIR/wordlists`).

