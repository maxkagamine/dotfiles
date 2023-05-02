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
