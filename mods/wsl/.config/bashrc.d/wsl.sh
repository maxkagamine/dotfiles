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

ee() {
  open "${1:-.}" && exit
}

vs() {
  if sln=$(find . -maxdepth 1 -iname '*.sln' -print -quit | grep .); then
    realpath "$sln"
    open "$sln"
  elif [[ $PWD == '/' ]]; then
    echo 'No solution file' >&2
    return 1
  else
    (cd .. && vs)
  fi
}

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
if [[ ${precmd_functions[*]} != *windows_terminal_precmd* ]]; then
  precmd_functions+=(windows_terminal_precmd)
fi

# dotnet bash completion (dotnet is aliased to the Windows version, via a
# wrapper so starship can see it, since I mainly target Linux through docker
# containers and haven't yet needed the Linux version installed)
function _dotnet_bash_complete() {
  local cur="${COMP_WORDS[COMP_CWORD]}" IFS=$'\r\n'
  local candidates
  read -d '' -ra candidates < <(dotnet complete --position "${COMP_POINT}" "${COMP_LINE}" 2>/dev/null)
  read -d '' -ra COMPREPLY < <(compgen -W "${candidates[*]:-}" -- "$cur")
}
complete -f -F _dotnet_bash_complete dotnet
