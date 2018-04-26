set -eE # -E to trap errors within functions with ERR
shopt -s nullglob

export PATH="/home/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
export MSYS=winsymlinks:nativestrict

trap 'task-end error' ERR
trap 'printf "\nPress enter to close... "; read -s' EXIT

printf '\e]0;Environment Setup\a'

# Task output functions

intask=0

group() {
	local line=$(printf '%.0sq' $(seq 1 $(($(tput cols) - ${#1} - 4))))
	printf '\n\e(0qq\e(B \e[1m%s\e[m \e(0%s\e(B\n' "$1" "$line"
}

task-start() {
	echo "$1"
	intask=1
}

task-end() {
	# Usage: task-end [(done|error|warning|*) [message]]
	[[ $intask == 0 ]] && return
	local msg=${2:-${1:-done}}
	local color='\e[m'
	case $1 in
		done|'') color='\e[1;32m' ;;
		error) color='\e[1;31m' ;;
		warning) color='\e[1;33m' ;;
	esac
	local length=$((${#msg} + 4))
	printf '\r\e[1A\e[%sC' $(($(tput cols) - $length))
	printf "[ $color$msg\e[m ]"
	intask=0
}

# Utility functions

command-exists() {
	command -v "$1" > /dev/null 2>&1
}

recycle() {
	local p
	for p in "$@"; do
		../home/bin/nircmdc moverecyclebin "$p"
	done
}

symlink-all() {
	# Usage: symlink-all FROM TO
	# Creates symlinks in TO for each item in FROM directory, replacing
	# existing symlinks and moving existing files/directories to recycle bin.
	local x
	for x in "$1"/*; do
		local dest="$2/$(basename "$x")"
		if [[ -e $dest && ! -L $dest ]]; then
			recycle "$dest"
		fi
	done
	find "$(realpath "$1")" -mindepth 1 -maxdepth 1 -exec ln -sft "$2" {} +
}

add-to-path() {
	# Adds each dir given to start of user PATH and prints
	# the dir unless already in user PATH (by exact match)
	local path=$(reg query 'HKEY_CURRENT_USER\Environment' //v PATH | perl -ne 's/^.*?_SZ\s+// && print')
	local i dir dirs=("$@") modified
	for (( i=$#-1; i>=0; i-- )); do
		dir=$(cygpath -aw "${dirs[$i]}")
		if [[ ";$path;" != *";$dir;"* ]]; then
			path="$dir;$path"
			modified=1
			echo "$dir"
		fi
	done
	if [[ $modified ]]; then
		reg add 'HKEY_CURRENT_USER\Environment' //v PATH //d "$path" //f > /dev/null
	fi
}
