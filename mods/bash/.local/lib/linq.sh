# Copyright (c) Max Kagamine
# Licensed under the Apache License, Version 2.0
#
# shellcheck shell=bash

append() { cat; echo "$@"; }
average() { awk -v f="${1:-1}" "${@:2}" 'BEGIN { sum = 0 } { sum += $f } END { if (NR == 0) exit 1; print sum / NR }'; }
distinct() { awk '!x[$0]++'; } # uniq but without needing to be sorted first (https://stackoverflow.com/a/11532197)
first() { awk 'NR == 1 { print; exit } END { exit NR != 1 }'; }
firstordefault() { take 1; }
last() { awk 'END { if (NR == 0) exit 1; print }'; }
lastordefault() { takelast 1; }
max() { awk -v f="${1:-1}" "${@:2}" 'NR == 1 || $f > max { max = $f } END { if (NR == 0) exit 1; print max }'; }
maxby() { awk -v f="${1:-1}" "${@:2}" 'NR == 1 || $f > max { max = $f; line = $0 } END { if (NR == 0) exit 1; print line }'; }
min() { awk -v f="${1:-1}" "${@:2}" 'NR == 1 || $f < min { min = $f } END { if (NR == 0) exit 1; print min }'; }
minby() { awk -v f="${1:-1}" "${@:2}" 'NR == 1 || $f < min { min = $f; line = $0 } END { if (NR == 0) exit 1; print line }'; }
prepend() { echo "$@"; cat; }
range() { seq "$1" "$(( $1 + $2 - 1 ))"; }
single() { awk 'NR == 1 { line = $0 } NR > 1 { exit 1 } END { if (NR != 1) exit 1; print line }'; }
singleordefault() { awk 'NR == 1 { line = $0 } NR > 1 { exit 1 } END { if (NR == 1) print line }'; }
skip() { tail -n "+$(( $1 + 1 ))" "${@:2}"; }
skiplast() { head -n "-$1" "${@:2}"; }
sum() { awk -v f="${1:-1}" "${@:2}" 'BEGIN { sum = 0 } { sum += $f } END { print sum }'; }
take() { head -n "$@"; }
takelast() { tail -n "$@"; }
