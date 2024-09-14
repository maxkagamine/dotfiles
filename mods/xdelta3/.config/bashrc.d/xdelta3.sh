# shellcheck shell=bash

# Use more memory to drastically speed up xdelta3 and improve compression
export XDELTA='-v -B536870912 -W16777216'
