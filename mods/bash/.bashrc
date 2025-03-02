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
if [[ ! $bash_preexec_imported ]]; then
  unset PROMPT_COMMAND
  # shellcheck source-path=SCRIPTDIR source=.local/lib/bash-preexec.sh
  . ~/.local/lib/bash-preexec.sh
fi

# Shell config
shopt -s histappend globstar
bind 'set completion-ignore-case on'
#bind 'set colored-stats on'
bind '"\e[3;5~": kill-word' # Ctrl+Del
bind '"\C-H": backward-kill-word' # Ctrl+Backspace (note: some terminals send a regular backspace when ctrl+backspace is pressed)
eval "$(dircolors -b ~/.config/dircolors)"
HISTSIZE=10000
HISTTIMEFORMAT='%Y-%m-%d %T  '
export LESS='-FRX'

if [[ $TERM_PROGRAM == 'vscode' ]]; then
  export EDITOR='code -w'
fi

# Automatically try .exe extension and node modules (like npx) if not in PATH
command_not_found_handle() {
  if command -v "$1.exe" &>/dev/null; then # Windows
    "$1.exe" "${@:2}"
  elif [[ -x "./node_modules/.bin/$1" ]]; then # Node
    "./node_modules/.bin/$1" "${@:2}"
  elif [[ -x /usr/lib/command-not-found ]]; then # Ubuntu
    /usr/lib/command-not-found -- "$1"
  else
    printf -- '-bash: %s: command not found\n' "$1" >&2
    return 127
  fi
}

__command_completion() {
  local word=${COMP_WORDS[COMP_CWORD]}
  # shellcheck disable=SC2312
  if [[ $word == */* ]]; then
    readarray -t COMPREPLY < <(compgen -c "$word")
  else
    readarray -t COMPREPLY < <(
      compgen -c "${COMP_WORDS[COMP_CWORD]}" | grep -Piv '\.dll$' | sed 's/\.exe$//i'
      PATH="node_modules/.bin" compgen -c "${COMP_WORDS[COMP_CWORD]}" | grep -Pv '\.(exe|cmd|ps1)$')
  fi
}

complete -I -d -F __command_completion

# General aliases
alias .e='code "$DOTFILES_DIR"'
alias .r='. ~/.bashrc'
alias cd='>/dev/null cd'
alias clip='xsel -bi'
alias grep='grep --color=auto'
alias ll='ls -Al'
alias ls='ls -hv --color=auto --group-directories-first'
alias tsv="column -ts $'\t' -W0"
alias unclip='xsel -bo'
alias x="xargs -d '\n' -L 1"
alias xx="xargs -d '\n'"

# Causes aliases to be resolved when running sudo
alias sudo='sudo '

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

distinct() {
  # uniq but without needing to be sorted first
  # https://stackoverflow.com/a/11532197
  awk '!x[$0]++'
}

clips() {
  # Clipboard monitor, can be fed to xargs, or a variable name can be given as
  # an argument to readarray the copied lines into an array.
  if [[ $1 ]]; then
    readarray -t "$1" < <(clips | tee /dev/stderr)
  else
    local x y
    x=$(unclip)
    while true; do
      y=$(unclip)
      if [[ $y != "$x" ]]; then
        echo "$y"
        x="$y"
      fi
    done
  fi
}

parallel() {
  # Helper function for running N tasks in parallel (defaults to number of
  # cores). Example: for f in *; do somejob & parallel; done; wait
  if (( $(jobs -rp | wc -l) >= ${1:-$(nproc)} )); then
    wait -n
  fi
}

colors() { # Prints a grid of ansi color & text style escapes
  local s c x
  for s in '' {1..5} 7 9 {40..47}; do
    [[ $s ]] && s+=';'
    for c in {30..37}; do
      x=2; (( ${#s} == 3 )) && x=1
      printf '\e[%s%sm%-8s\e[m%'$x's' "$s" "$c" "$(printf '\\e[%s%sm' "$s" "$c")" ''
    done
    echo
  done
}

# For dry runs / printing arrays
q() { printf '%q ' "$@"; printf '\n'; }
n() { printf '%s\n' "$@"; }

# Load mods
for mod in ~/.config/bashrc.d/*.sh; do
  # shellcheck disable=SC1090
  . "$mod"
done
