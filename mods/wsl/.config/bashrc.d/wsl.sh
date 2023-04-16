# shellcheck shell=bash

CDPATH='.:~:~/Projects:/mnt/c/Users/max/Projects:/mnt/s:/mnt/c/Users/max'

alias open='wslview'
alias e='exp'
alias ee='exp;exit'

exp() {
  (( $# == 0 )) && set .
  wslview "$@"
}

hide() { n "$@" | x wslpath -w | x attrib.exe +h; }
unhide() { n "$@" | x wslpath -w | x attrib.exe -h; }
recycle() { n "$@" | x wslpath -w | x nircmdc.exe moverecyclebin; }

# Alt+V pastes Windows paths as WSL paths
bind -x '"\ev": __paste_wslpath'
__paste_wslpath() {
  local before="${READLINE_LINE:0:$READLINE_POINT}"
  local after="${READLINE_LINE:$READLINE_POINT}"
  local insert
  insert=$(printf '%q' "$(wslpath "$(unclip | sed -E 's/^"|"$//g')")")
  READLINE_LINE="${before}${insert}${after}"
  ((READLINE_POINT += ${#insert}))
}

