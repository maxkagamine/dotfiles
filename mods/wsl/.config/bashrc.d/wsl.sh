# shellcheck shell=bash

CDPATH='.:~:~/Projects:/mnt/c/Users/max/Projects:/mnt/s:/mnt/c/Users/max'

alias .e='code "$DOTFILES_DIR"'

w() {
  [[ $# == 0 || ( $# == 1 && ! $1 ) ]] && set .
  local p; for p; do
    wslpath -w "$p" | sed 's/^\\\\wsl$\\Ubuntu\\/L:\\/'
  done
}

exp() {
  explorer.exe "$(w "$1")" || true
}

hide() {
  w "$@" | xargs -d '\n' -L 1 attrib.exe +h
}

unhide() {
  w "$@" | xargs -d '\n' -L 1 attrib.exe -h
}

recycle() {
  w "$@" | xargs -d '\n' -L 1 nircmdc.exe moverecyclebin
}
