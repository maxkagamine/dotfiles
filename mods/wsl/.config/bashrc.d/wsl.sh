# shellcheck shell=bash

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
