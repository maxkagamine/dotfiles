# shellcheck shell=bash

if [[ $HOSTNAME == 'Oblivion' ]]; then
  # Omit network drive (S:) so that tab completion doesn't hang when not
  # connected to VPN
  CDPATH='.:~:~/Projects:/mnt/c/Users/max/Projects:/mnt/c/Users/max'
else
  CDPATH='.:~:~/Projects:/mnt/c/Users/max/Projects:/mnt/s:/mnt/c/Users/max'
fi

export BROWSER=~/.local/bin/open

e() {
  open "${1:-.}"
}

alias ee='e; exit'
alias vs='open *.sln'

alias ffplay='&>/dev/null ffplay.exe -hide_banner -nodisp -autoexit'

hide() { n "$@" | x wslpath -w | x attrib.exe +h; }
unhide() { n "$@" | x wslpath -w | x attrib.exe -h; }
recycle() { n "$@" | x wslpath -w | x nircmdc.exe moverecyclebin; }
hxd() { (n "$@" | x wslpath -w | xx /mnt/c/Program\ Files/HxD/HxD.exe &); }

# Faster than doing it from Windows when there's a ton of little files
empty-sovngarde-recycle-bin() {
  ssh sovngarde 'rm -rfv /mnt/user/*/\$RECYCLE.BIN/*'
}

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

# https://learn.microsoft.com/en-us/windows/terminal/tutorials/new-tab-same-directory
windows_terminal_precmd() {
  printf "\e]9;9;%s\e\\" "$(wslpath -w "$PWD")"
}
precmd_functions+=(windows_terminal_precmd)
