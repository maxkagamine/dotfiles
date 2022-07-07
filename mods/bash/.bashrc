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
export LESS='-FRX --mouse --wheel-lines 2'

# cd to clipboard (bind nonsense courtesy of fzf's key-bindings.bash)
# shellcheck disable=SC2016
bind -m emacs-standard '"\ev": " \C-b\C-k \C-u`__cd_to_clipboard`\e\C-e\er\C-m\C-y\C-h\e \C-y\ey\C-x\C-x\C-d"'
__cd_to_clipboard() {
  local p; p=$(unclip) || return 1
  if [[ $p == *:\\* ]] && command -v wslpath &>/dev/null; then
    p=$(wslpath "$p") || return 1
  fi
  printf 'cd %q' "$p"
}

# General aliases
alias .r='. ~/.bashrc'
alias cd='>/dev/null cd'
alias clip='xsel -bi'
alias dig='dig +noall +answer'
alias exiftool='exiftool -g -overwrite_original'
alias ffmpeg='ffmpeg -hide_banner'
alias ffprobe='ffprobe -hide_banner'
alias grep='grep --color=auto'
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

# Load mods
for mod in ~/.config/bashrc.d/*.sh; do
  # shellcheck disable=SC1090
  . "$mod"
done
