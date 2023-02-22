# shellcheck shell=bash

CDPATH='.:~:~/Projects:/mnt/c/Users/max/Projects:/mnt/s:/mnt/c/Users/max'

exp() { w "${1:-.}" | x explorer.exe || true; }
hide() { w "$@" | x attrib.exe +h; }
unhide() { w "$@" | x attrib.exe -h; }
recycle() { w "$@" | x nircmdc.exe moverecyclebin; }

w() {
  local path
  for path; do
    printf '%s\n' "$(wslpath -w "$path")"
  done
}

# Alt+V pastes Windows paths as WSL paths
bind -x '"\ev": __paste_wslpath'
__paste_wslpath() {
  local before="${READLINE_LINE:0:$READLINE_POINT}"
  local after="${READLINE_LINE:$READLINE_POINT}"
  local insert; insert=$(wslpath "$(unclip)")
  READLINE_LINE="${before}${insert}${after}"
  ((READLINE_POINT += ${#insert}))
}

