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

ugoira-to-avif() { # See also ugoira-to-apng in docker.sh
  local DEFAULT_CRF=20
  if [[ ! -f animation.json || $1 =~ ^(--help|-h)$ ]]; then
    echo 'Run from directory containing frames & animation.json.' >&2
    echo "CRF environment variable controls crf, defaults to $DEFAULT_CRF." >&2
    return 1
  fi
  # For whatever reason, the last frame must be specified twice (bug in concat
  # demuxer?). Can confirm correct (or close enough) frame times using:
  #   ffprobe *.avif -show_frames | grep pkt_duration_time=
  jq -r '(.[]|"file '\''\(.file)'\''\nduration \(.delay)ms"),(.[-1]|"file '\''\(.file)'\''")' \
    animation.json > animation.txt || return $?
  # VFR results in the same number of frames (plus one due to the above) and
  # thus smaller file size / faster encode. Capped at 60fps (defaults to 25
  # otherwise). AOM is slower than SVT but seems to achieve better quality.
  ffmpeg -y -safe 0 -f concat -i animation.txt \
    -c:v libaom-av1 -crf "${CRF:-$DEFAULT_CRF}" -fps_mode vfr -r 60 \
    "${PWD##*/}.avif" 2>&1 | grep -v 'deprecated pixel format used'
}
