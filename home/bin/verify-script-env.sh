#!/usr/bin/env bash

group() {
	local line=$(/usr/bin/printf '%.0sq' $(/usr/bin/seq 1 $(($(/usr/bin/tput cols) - ${#1} - 4))))
	/usr/bin/printf '\n\e(0qq\e(B \e[1m%s\e[m \e(0%s\e(B\n' "$1" "$line"
}

check() {
	if /usr/bin/grep -q "$2" <<<"$1"; then
		/usr/bin/printf '\e[32m✓ %s\e[m\n' "$1"
	else
		/usr/bin/printf '\e[1;31m✘ %s\e[m\n' "$1"
	fi
}

group 'Path'
tr ':' '\n' <<<"$PATH"

group 'Arguments'
[[ $# != 0 ]] && /usr/bin/printf '%s\n' "$@"

group 'Environment'
echo "PWD = $(pwd)"
echo
check "MSYSTEM = $MSYSTEM" '^MSYSTEM = MINGW64$'
check "MSYS = $MSYS" 'winsymlinks:nativestrict'
check "EDITOR = $EDITOR" '^EDITOR = nano$'
check "$([[ $- == *i* ]] && echo 'Interactive' || echo 'Not interactive')" '^Not interactive$'
check "$(shopt -q login_shell && echo 'Login shell' || echo 'Not login shell')" '^Not login shell$'
check "$(type cut 2>&1 | /usr/bin/head -n1)" '^cut is /usr/bin/cut$' # Path
check "$(type ls 2>&1 | /usr/bin/head -n1)" '^ls is /usr/bin/ls$'    # Aliases
check "$(type gg 2>&1 | /usr/bin/head -n1)" 'type: gg: not found$'   # Functions
check "$(type ffmpeg 2>&1 | /usr/bin/head -n1)" 'ffmpeg is /home/bin/ffmpeg/ffmpeg' # ~/bin/* in path
check "$(type ConEmu64 2>&1 | /usr/bin/head -n1)" 'ConEmu64 is /c/Program Files/ConEmu/ConEmu64' # Inherited path

echo
echo 'Press enter to exit.'
read
