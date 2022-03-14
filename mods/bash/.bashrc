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
alias tsv="column -ts $'\t' -W0"
alias unclip='xsel -bo'

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

weigh() {
  if [[ $1 =~ ^(--help|-h)$ ]]; then
    cat >&2 <<EOF
Usage: weigh [-z] [<file|directory>...]
Shows total size of files or stdin, gzipped if -z.
EOF
    return 1
  fi
  local p f gz=
  [[ $1 == '-z' ]] && { gz=1; shift; }
  [[ $# == 0 ]] && set -- -
  exec 5<&0
  for p; do
    if [[ -d "$p" ]]; then
      find "$p" -type f
    else
      echo "$p"
    fi
  done | while read -r f; do
    [[ $f != - ]] && printf '\e[1;30m%s\e[m' "${f:0:$((COLUMNS-1))}" >&2
    if [[ $gz ]]; then
      gzip -c "$f" <&5 | wc -c
    else
      wc -c "$f" <&5 | cut -d' ' -f1
    fi
    [[ $f != - ]] && printf '\r\e[K' >&2
  done | \
    paste -sd+ | bc | \
    numfmt --to=iec-i --suffix=B | sed 's/[a-z]/ \0/i'
  exec 5<&-
}

# Load mods
for mod in ~/.config/bashrc.d/*.sh; do
  # shellcheck disable=SC1090
  . "$mod"
done
