# Copyright (c) Max Kagamine
# Licensed under the Apache License, Version 2.0
#
# shellcheck shell=bash

alias exiftool='exiftool -g -overwrite_original'

# https://photo.stackexchange.com/a/69742
alias exifstrip='exiftool -all= -TagsFromFile @ -ColorSpaceTags'
