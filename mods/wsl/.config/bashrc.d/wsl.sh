# shellcheck shell=bash

CDPATH='.:/mnt/s:/mnt/c/Users/max:/mnt/c/Users/max/Projects'
alias cd='>/dev/null cd'

# shellcheck disable=SC2139
alias .e="code '$(wslpath -w "$DOTFILES_DIR")'"

exp() {
  explorer.exe "$(wslpath -w "${1:-.}")" || true
}

hide() {
  attrib.exe +h "$(wslpath -w "$1")"
}

unhide() {
  attrib.exe -h "$(wslpath -w "$1")"
}

recycle() {
  local p
  for p; do nircmdc.exe moverecyclebin "$(wslpath -w "$p")"; done
}
