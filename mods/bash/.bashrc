# shellcheck shell=bash

PATH="$HOME/.local/bin:$PATH"

export DOTFILES_DIR
DOTFILES_DIR=$(realpath -m ~/.bashrc/../../..)

# Bail if non-interactive shell
[[ $- == *i* ]] || return

# Shell config
shopt -s histappend checkwinsize globstar nullglob extglob
bind 'set completion-ignore-case on'
bind 'set colored-stats on'
HISTSIZE=10000
HISTTIMEFORMAT='%Y-%m-%d %T  '

# General aliases
alias clip='xsel -bi'
alias dig='dig +noall +answer'
alias fd='fdfind'
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

# Enable source-highlight if installed
if command -v source-highlight &>/dev/null; then
  export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
fi

# Enable fzf if installed
# shellcheck disable=SC1091
if command -v fzf &>/dev/null; then
  . /usr/share/doc/fzf/examples/key-bindings.bash 2>/dev/null
  . /usr/share/doc/fzf/examples/completion.bash 2>/dev/null

  export FZF_COMPLETION_OPTS="--ansi --preview '( [[ -d {} ]] && ${BASH_ALIASES[ls]} -x --color=always {} || less -RX {} ) | head -200'"
  export FZF_CTRL_T_OPTS=$FZF_COMPLETION_OPTS
  export FZF_CTRL_T_COMMAND='_fzf_compgen_path .'
  export FZF_ALT_C_OPTS=$FZF_COMPLETION_OPTS
  export FZF_ALT_C_COMMAND='_fzf_compgen_dir .'

  _fzf_compgen_path() { fd --hidden --exclude .git --color always . "$@"; }
  _fzf_compgen_dir() { _fzf_compgen_path "$1" --type d; }
fi

# Load mods
for mod in ~/.config/bashrc.d/*.sh; do
  # shellcheck disable=SC1090
  . "$mod"
done
