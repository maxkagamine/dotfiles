# Copyright (c) Max Kagamine
# Licensed under the Apache License, Version 2.0
#
# shellcheck shell=bash

alias ffmpeg='ffmpeg -hide_banner'
alias ffplay='ffplay -hide_banner'
alias ffprobe='ffprobe -hide_banner'

flac() {
  local f
  for f; do
    ffmpeg -i "$f" -compression_level 12 "${f%.*}.flac" || return $?
  done
}

vmaf() {
  if (( $# < 2 )); then
    echo 'Usage: vmaf <distorted> <reference> [<stream mapping>]' >&2
    echo "Mapping should be the format '[0:a][1:b]' where 'a' and 'b' are the" >&2
    echo "stream indexes from the distorted and references inputs, respectively." >&2
    return 1
  fi
  local distorted=$1 reference=$2 stream_mapping=$3 output
  if ! output=$(ffmpeg -i "$distorted" -i "$reference" \
         -filter_complex "${stream_mapping}libvmaf" -f null - 2>&1) ||
     ! grep --color=never -Po '(?<=VMAF score: ).*' <<<"$output"; then
    echo "$output" >&2
    return 1
  fi
}
