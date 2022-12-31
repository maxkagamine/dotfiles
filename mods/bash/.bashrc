# shellcheck shell=bash

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  PATH="$HOME/.local/bin:$PATH"
fi

if [[ -d ~/.cargo && ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
  PATH="$HOME/.cargo/bin:$PATH"
fi

export DOTFILES_DIR
DOTFILES_DIR=$(realpath -m ~/.bashrc/../../..)

# Bail if non-interactive shell
[[ $- == *i* ]] || return

# Install bash-preexec (https://github.com/rcaloras/bash-preexec)
# shellcheck source-path=SCRIPTDIR source=.local/lib/bash-preexec.sh
. ~/.local/lib/bash-preexec.sh

# Shell config
shopt -s histappend globstar
bind 'set completion-ignore-case on'
bind 'set colored-stats on'
bind '"\e[3;5~": kill-word' # Ctrl+Del
bind '"\C-H": backward-kill-word' # Ctrl+Backspace (note: some terminals send a regular backspace when ctrl+backspace is pressed)
HISTSIZE=10000
HISTTIMEFORMAT='%Y-%m-%d %T  '
export LESS='-FRX --mouse --wheel-lines 2'
export UNZIP='-O cp932 -DD' # Extract Windows zips using Japanese codepage, don't set timestamp

if [[ $TERM_PROGRAM == 'vscode' ]]; then
  export EDITOR='code -w'
fi

# Alt+V cd to clipboard (bind nonsense courtesy of fzf's key-bindings.bash)
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

# For dry runs / printing arrays
q() { printf '%q ' "$@"; printf '\n'; }
n() { printf '%s\n' "$@"; }

# Load mods
for mod in ~/.config/bashrc.d/*.sh; do
  # shellcheck disable=SC1090
  . "$mod"
done
