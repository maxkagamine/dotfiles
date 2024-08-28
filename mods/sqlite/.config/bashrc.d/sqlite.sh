# shellcheck shell=bash

alias sql='sqlite3'

complete -f -X '!@(--*|*.@(db|sqlite|sqlar))' -W '
  --append --ascii --bail --batch --box --column --cmd --csv --deserialize
  --echo --init --noheader --header --help --html --interactive --json --line
  --list --lookaside --markdown --maxsize --memtrace --mmap --newline --nofollow
  --nonce --nullvalue --pagecache --quote --readonly --safe --separator --stats
  --table --tabs --version --vfs --zip
' sqlite3 sql
