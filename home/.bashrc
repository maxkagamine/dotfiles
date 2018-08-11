# Prepend user bin to PATH

if [[ ":$PATH:" != *":$HOME/.local/bin:$HOME/bin:"* ]]; then
	export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

# Redirect to home dir if within a bind mount

__redir() {
	local line from to cur=$(pwd)
	while read -r line; do
		from=$(awk '{ gsub(/\\040/, " ", $1); print $1 }' <<<"$line")
		if [[ "$cur/" == "$from/"*  ]]; then
			to=$(awk '{ gsub(/\\040/, " ", $2); print $2 }' <<<"$line")
			cd "$to/${cur:${#from}}"
			break
		fi
	done < /etc/fstab
}

__redir; unset __redir

# Prompt

. /usr/lib/git-core/git-sh-prompt

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1

__prompt-command() {

	local err=$?

	local def='\[\e[0;0m\]'
	local red='\[\e[1;31m\]'
	local yel='\[\e[0;33m\]'
	local cyn='\[\e[0;36m\]'

	PS1='\[\e]0;\w\a\]'              # Set window title
	PS1+='\n'                        # Newline
	(( $err )) && PS1+="$red$err "   # Exit code if error
	PS1+="$yel\w$cyn"                # Current directory
	PS1+=$(__git_ps1)                # Git branch
	PS1+="$def\n"                    # Newline
	PS1+='\$ '                       # Dollar sign or hash

	# Alias empty command to `git status` when in git repo
	_L="$(history 1)"; [[ "$_L" == "$_X" ]] && \
	git rev-parse --is-inside-work-tree &>/dev/null && git status; _X="$_L"

}

PROMPT_COMMAND='__prompt-command'

# Variables & shell config

HISTTIMEFORMAT='%Y-%m-%d %T  ' # Display timestamp in history

export EDITOR=nano # Avert ye eyes, setting default editor to nano

shopt -s globstar

. ~/bin/fzf-completion.bash
. ~/bin/fzf-key-bindings.bash

# Start gpg agent
# https://github.com/diablodale/pinentry-wsl-ps1

GPG_AGENT_PID=$(pgrep gpg-agent)
if [[ ! $GPG_AGENT_PID ]]; then
	gpgconf --launch gpg-agent && GPG_AGENT_PID=$(pgrep gpg-agent)
fi

export GPG_AGENT_INFO="$HOME/.gnupg/S.gpg-agent:$GPG_AGENT_PID:1"
export GPG_TTY=$(tty)
export SSH_AUTH_SOCK="/tmp/S.gpg-agent.ssh"

unset SSH_AGENT_PID
unset GPG_AGENT_PID

# General aliases

alias ls='ls -Ah --color=auto'
alias ll='ls -l'
alias grep='grep --color=auto'
alias dig='dig +noall +answer'
alias digx='dig @8.8.8.8'
alias ffmpeg='ffmpeg -hide_banner'
alias ffprobe='ffprobe -hide_banner'
alias yt='youtube-dl --netrc'
alias ytmp3='yt -xf "best[format_id!=economy]" --audio-format mp3 --audio-quality 0' # 'economy' prevents downloading niconico's low quality, high traffic mode videos
alias exiftool='exiftool -g'
alias exifstrip='exiftool -all='
alias whois='whois -H'
alias halt='shutdown.exe /s /hybrid /t 0'
alias reboot='shutdown.exe /r /t 0'
alias gpg='gpg2'
alias dokku='ssh dokku'
alias .e='code ~/.bashrc' # Edit bashrc
alias .l='code ~/.bashrc_local' # Edit local bashrc
alias .r='. ~/.bashrc' # Reload bashrc

# Node aliases

alias ni='npm i'
alias nid='ni -D'
alias nu='npm un'
alias nud='nu -D'
alias ns='npm start'
alias nr='npm run'
alias nrb='nr build'
alias nrw='nr watch'
alias nt='npm test'
alias nc='npm-check -su'
alias nis='ni && ns'
alias nir='ni && nr'
alias nirb='ni && nrb'
alias nirw='ni && nrw'

__npm-run-complete() {
	# Faster than `npm completion` and handles scripts with spaces in the name better
	local cur
	local options
	_get_comp_words_by_ref -n : cur
	readarray -t options < <(jq -r '.scripts | keys | join("\n")' package.json 2>/dev/null | sed 's/\r//g')
  readarray -t COMPREPLY < <(compgen -W "$(printf '%q ' "${options[@]}")" -- "$cur" | awk '/ / { print "'\''"$0"'\''" } /^[^ ]+$/ { print $0 }') # Magic https://stackoverflow.com/a/40944195
	__ltrim_colon_completions "$cur"
}
complete -F __npm-run-complete nr nir

# Git aliases & functions

alias g='git'
alias gl='git log'
alias gd='git diff'
alias ga='git add'
alias gc='git commit'
alias gb='git branch-fzf'
alias gf='git fetch'
alias gr='git rebase'
alias grh='git reset HEAD'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gch='git ch'
alias gpl='git pull'
alias gps='git push'
alias gcol='git checkout-latest'

gg() {
	# Usage: gg [-A] [<git commit options>] [bare message...]
	# Commits everything if -A or nothing staged
	# https://kagami.ne/gg
	git rev-parse --is-inside-work-tree > /dev/null || return
	local opts=()
	local staged=$(git diff --cached --quiet)$?
	while [[ ${1::1} == '-' ]]; do
		if [[ $1 == '--' ]]; then
			shift; break
		elif [[ $1 == '-A' ]]; then
			staged=0; shift
		else
			opts+=("$1"); shift
		fi
	done
	if (( $# > 0 )); then
		opts+=(-m "$*")
	fi
	if [[ $staged == 0 ]]; then
		git add -A || return
	elif [[ $(git diff-files; git ls-files -o --exclude-standard "$(git rev-parse --show-toplevel)") ]]; then
		# Only some changes staged
		echo 'Committing only staged changes.'
	fi
	git commit "${opts[@]}"
}

fus() {
	# https://kagami.ne/fusrodah
	if [[ $* =~ ^ro\ dah ]]; then
		git nuke && sweetroll --sfx fusrodah
	else
		( cd "$(git rev-parse --show-toplevel)" && # git clean operates in current dir
			git reset --hard && git clean -fd && sweetroll --sfx fus )
	fi
	sweetroll $?
}

. /usr/share/bash-completion/completions/git
__git_complete g __git_main
__git_complete gl _git_log
__git_complete gd _git_diff
__git_complete gb _git_branch
__git_complete gr _git_rebase
__git_complete gco _git_checkout
__git_complete gpl _git_pull
__git_complete gcol _git_checkout
__git_complete gg _git_commit

# Functions

exp() {
	explorer.exe "$(wslpath -w "${1:-.}")" || true
}

code() {
	if [[ $# == 0 || $1 =~ ^- ]]; then
		command code "$@"
	else
		local p paths=()
		for p in "$@"; do
			paths+=("$(wslpath -aw "$@")")
		done
		command code "${paths[@]}"
	fi
}

c() {
	mkdir -vp -- "$1" | head -n1 && cd -- "$1"
}

hide() {
	attrib.exe +h "$(wslpath -w "$1")"
}

unhide() {
	attrib.exe -h "$(wslpath -w "$1")"
}

treelist() {
	tree --noreport "$@" | tail -n +2 | awk '{print substr($0,5,length)}'
}

clip() {
	perl -pe 'chomp if eof' | clip.exe
}

unclip() {
	powershell.exe -noprofile -command 'Get-Clipboard'
}

tclip() {
	tee >(clip)
}

randpw() {
	local chars='A-Za-z0-9'
	if [[ "$1" == '-c' ]]; then
		chars="$2"
		shift; shift
	elif [[ "$1" == '-x' ]]; then
		chars="$chars!\"#\$%&'()*+,-./:;<=>?[\\]^_{|}~"
		shift
	fi
	tr -dc "$chars" < /dev/urandom | head -c ${1-20}; echo
}

wtfismyip() {
	curl -Ss https://wtfismyip.com/text
}

wtfismylocation() {
	curl -Ss http://ip-api.com/line/?fields=country,regionName,city | \
		tac | perl -pe 'unless(eof){s/\n/, /g}'
}

wtfislisteningon() {
	# Linux netstat not yet supported https://github.com/Microsoft/WSL/issues/2249
	net.exe session &>/dev/null || { echo 'Run WSL as administrator.' >&2; return 1; }
	netstat.exe -abno | \
		grep -P '^(  TCP|  UDP| \S)' | \
		grep -PA1 --no-group-separator -e ':'"${1:-\\d+}"'\s+\S+\s+LISTENING' | \
		sed 'N;s/\n//' | \
		awk -v OFS='\t' '{ print $1, gensub(/.*:([0-9]+)/, "\\1", "g", $2), substr($6, 0, 1) != "[" ? "System" : substr(substr($0, 0, length($0) - 1), index($0, $5) + length($5) + 2), $5 }' | \
		{ echo $'Proto\tPort\tProcess\tPID'; sort -nuk2; } | \
		column -ts $'\t'
}

argv() {
	printf '%s\n' "$@"
}

retry() {
	# Usage: retry [-d <delay>] <command>
	# Retries <command> until success, waiting <delay>
	# seconds (default 1 hour) between retries
	local delay=3600
	if [[ $1 == -d* ]]; then
		delay=${1#-d}; shift
		[[ -z $delay ]] && { delay=$1; shift; }
		[[ $delay =~ ^[0-9]+$ ]] || { echo 'Invalid delay' >&2; return 1; }
	fi
	while ! bash -lic "$1"' "$@"' "$@"; do # Handles aliases
		printf '\e[1;31mretry: command failed, next attempt at %s\e[m\n' \
			"$(date -d "$delay seconds" +%X | tr -d ' ')"
		sleep $delay
	done
}

recycle() {
	local p
	for p in "$@"; do
		nircmdc.exe moverecyclebin "$(wslpath -w "$p")"
	done
}

# Load .bashrc_local, if exists

if [[ -f ~/.bashrc_local ]]; then
	. ~/.bashrc_local
fi
