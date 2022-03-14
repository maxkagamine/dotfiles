# shellcheck shell=bash

[[ ":$PATH:" == *":$HOME/.local/bin:"* ]] || \
  PATH="$HOME/.local/bin:$PATH"

export DOTFILES_DIR
DOTFILES_DIR=$(realpath -m ~/.bashrc/../../..)

# Bail if non-interactive shell
[[ $- == *i* ]] || return

# Shell config
shopt -s histappend globstar
bind 'set completion-ignore-case on'
bind 'set colored-stats on'
HISTSIZE=10000
HISTTIMEFORMAT='%Y-%m-%d %T  '

# General aliases
alias .r='. ~/.bashrc'
alias cd='>/dev/null cd'
alias clip='xsel -bi'
alias dig='dig +noall +answer'
alias ffmpeg='ffmpeg -hide_banner'
alias ffprobe='ffprobe -hide_banner'
alias grep='grep --color=auto'
alias less='less -FRX'
alias ll='ls -Al'
alias ls='ls -hv --color=auto --group-directories-first'
alias tree='tree --dirsfirst -aCI ".git|node_modules"'
alias unclip='xsel -bo'
alias tsv="column -ts $'\t' -W0"

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

wherethehellami() {
  curl -Ss ipinfo.io/"$1" | jq -r '[.city,.region,.country]|join(", ")'
}

append_crc32() {
  (
    set -eo pipefail
    if [[ $# == 0 || $1 =~ ^(--help|-h)$ ]]; then
      cat >&2 <<EOF
Usage: append_crc32 [-n] <file>...
Puts (or updates) a file's crc32 hash in its filename.
-n  Dry run.
EOF
      exit 1
    fi
    if [[ $1 == '-n' ]]; then
      dry_run=1
      shift
    fi
    for f; do
      crc=$(crc32 "$f" | cut -f1)
      name=$(perl -pe 's/^(.*?)( ?\[[0-9a-f]{8}\])?(\.[^\.]+)?$/\1 ['"$crc"']\3/' <<<"$f")
      if [[ $dry_run ]]; then
        [[ $f != "$name" ]] && echo "$f -> $name"
      else
        mv -nv "$f" "$name"
      fi
    done
  )
}

# Load mods
for mod in ~/.config/bashrc.d/*.sh; do
  # shellcheck disable=SC1090
  . "$mod"
done
