# shellcheck shell=bash

alias exiftool='exiftool -g -overwrite_original'

# https://photo.stackexchange.com/a/69742
alias exifstrip='exiftool -all= -TagsFromFile @ -ColorSpaceTags'
