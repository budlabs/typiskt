
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

