### 2022.06.30.1

Fixed issue where program needed a restart to account
for new size of window.

Support for `--lines LINES` which will set the maximium
number of preview lines. This setting can also be set
in the config file (lines=2) or environment variable
TYPISKT_LINES.

Added `--details` option, which will write detailed
information about the last test to a file in  
`~/.cache/typiskt/details`.

Fixed issue with certain locales not printing the 
correct value due to different decimal separator.

Added support for XDG_CACHE_HOME.

Fixed an issue where escape codes of arrow keys
could appear in the prompt in excercise mode.
