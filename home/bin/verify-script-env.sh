#!/usr/bin/env bash

group() {
	local line=$(/usr/bin/printf '%.0sq' $(/usr/bin/seq 1 $(($(/usr/bin/tput cols) - ${#1} - 4))))
	/usr/bin/printf '\n\e(0qq\e(B \e[1m%s\e[m \e(0%s\e(B\n' "$1" "$line"
}

check() {
	if /bin/grep -q "$2" <<<"$1"; then
		/usr/bin/printf '\e[32m✓ %s\e[m\n' "$1"
	else
		/usr/bin/printf '\e[1;31m✘ Expected: %s\n  Actual: %s\e[m\n' "$2" "$1"
	fi
}

group 'Path'
/usr/bin/tr ':' '\n' <<<"$PATH"

group 'Arguments'
[[ $# != 0 ]] && /usr/bin/printf '%s\n' "$@"

group 'Environment'
echo "PWD = $(pwd)"
echo
check "$([[ $- == *i* ]] && echo 'Interactive' || echo 'Not interactive')" '^Not interactive$'
check "$(shopt -q login_shell && echo 'Login shell' || echo 'Not login shell')" '^Not login shell$'
check "EDITOR = $EDITOR" '^EDITOR = nano$' # Variable set by bashrc
check "$(type ls 2>&1 | /usr/bin/head -n1)" '^ls is /bin/ls$' # No aliases
check "$(type gg 2>&1 | /usr/bin/head -n1)" 'type: gg: not found$' # No functions
check "$(type sweetroll 2>&1 | /usr/bin/head -n1)" "^sweetroll is $HOME/bin/sweetroll$" # ~/bin in path
check "$(type cmd.exe 2>&1 | /usr/bin/head -n1)" '^cmd.exe is /mnt/c/Windows/System32/cmd.exe$' # Inherited path

echo
echo 'Press enter to exit.'
read
