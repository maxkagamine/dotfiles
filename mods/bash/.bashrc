# shellcheck shell=bash

PATH="$HOME/.local/bin:$PATH"

# Bail if non-interactive shell
[[ $- == *i* ]] || return

# Shell config
shopt -s histappend checkwinsize globstar nullglob extglob
bind 'set completion-ignore-case on'
HISTSIZE=10000
HISTTIMEFORMAT='%Y-%m-%d %T  '

# General aliases
alias clip='xsel -bi'
alias dig='dig +noall +answer'
alias ffmpeg='ffmpeg -hide_banner'
alias ffprobe='ffprobe -hide_banner'
alias grep='grep --color=auto'
alias less='less -FRX'
alias ls='ls -lAh --color=auto --group-directories-first'
alias unclip='xsel -bo'

# Reload bashrc
alias .r='. ~/.bashrc'

# General-use functions
mkcd() {
  mkdir -vp -- "$1" && cd -- "$1" || return
}

tclip() {
  tee >(clip)
}

wtfismyip() {
  curl -Ss https://wtfismyip.com/text
}

# Load mods
for mod in ~/.config/bashrc.d/*.sh; do
  # shellcheck disable=SC1090
  . "$mod"
done
