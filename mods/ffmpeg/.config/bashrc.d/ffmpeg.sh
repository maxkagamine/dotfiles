# Copyright (c) Max Kagamine
# Licensed under the Apache License, Version 2.0
#
# shellcheck shell=bash

export SVT_LOG=2 # warning

alias ffmpeg='ffmpeg -hide_banner'
alias ffplay='ffplay -hide_banner'
alias ffprobe='ffprobe -hide_banner'

flac() {
  local f
  for f; do
    ffmpeg -i "$f" -compression_level 12 "${f%.*}.flac" || return $?
  done
}

is_hdr() {
  if ffprobe -v quiet -show_streams -select_streams v "$1" |
     grep -qP '^color_transfer=(arib-std-b67|smpte2084)$'; then
    echo 1
  fi
}
