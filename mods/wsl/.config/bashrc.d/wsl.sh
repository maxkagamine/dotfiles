# shellcheck shell=bash

CDPATH='.:/home/max/Projects:/mnt/s:/mnt/c/Users/max'

alias .e='code "$DOTFILES_DIR"'

wp() {
  wslpath -w "${1:-.}" | sed 's/\\\\wsl$\\Ubuntu/L:/'
}

exp() {
  explorer.exe "$(wp "${1:-.}")" || true
}

hide() {
  attrib.exe +h "$(wp "$1")"
}

unhide() {
  attrib.exe -h "$(wp "$1")"
}

recycle() {
  local p
  for p; do nircmdc.exe moverecyclebin "$(wp "$p")"; done
}
