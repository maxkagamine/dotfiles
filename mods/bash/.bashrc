# shellcheck shell=bash disable=SC2120,SC2119

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
alias x="xargs -d '\n' -L 1 "
alias xx="xargs -d '\n' "

# Causes aliases to be resolved when running sudo or xargs (trailing space on x & xx above as well)
alias sudo='sudo '
alias xargs='xargs '

# General-use functions
mkcd() {
  mkdir -vp -- "$1" && cd -- "$1" || return
}

tclip() {
  tee >(clip "$@")
}

clips() {
  # Clipboard monitor. Can be fed to xargs, or a variable name can be given as
  # an argument to readarray the copied lines into an array.
  #
  # Examples:
  #   clips | xx gal                  # alias for xargs -d '\n' gallery-dl
  #   clips urls && gal "${urls[@]}"
  if [[ $1 ]]; then
    local output
    output=$(clips) && readarray -t "$1" <<<"$output"
  else
    (
      ok=
      n=0
      trap 'stty echo; [[ $ok ]] || printf "\e[2;7;31m Canceled \e[m\n" >&2' EXIT
      stty -echo # read -s only prevents echo for the brief moment that read is executing
      printf '\e[2;7;32m Press any key when done, ctrl+c to cancel \e[m\n' >&2
      x=$(unclip) || return 1
      while ! read -r -t 0.01 -N 1; do
        y=$(unclip < /dev/null) || return 1
        if [[ $y && $y != "$x" ]]; then
          echo "$y"
          if [[ ! -t 1 ]]; then # stdout redirected
            echo "$y" >&2
          fi
          x="$y"
          (( ++n ))
        fi
      done
      ok=1
      printf '\e[2;7;32m -- %s clips -- \e[m\n' "$n" >&2
    )
  fi
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

parallel() {
  # Helper function for running N tasks in parallel (defaults to number of
  # cores). Example: for f in *; do somejob & parallel; done; wait
  if (( $(jobs -rp | wc -l) >= ${1:-$(nproc)} )); then
    wait -n
  fi
}

colors() { # Prints a grid of ansi color & text style escapes
  local s c x l
  for s in '' {1..5} 7 9 {40..47}; do
    for c in '' {30..37}; do
      [[ $c ]] && l=5 || l=2
      [[ $s && $c ]] && x="$s;$c" || x="$s$c"
      printf '\e[%sm\\e[%sm\e[m%'$(( l - ${#x} + 1 ))'s' "$x" "$x" ''
    done
    echo
  done
}

guid() { # Prints & copies (or writes plain to stdout if pipe) a new UUID
  local uuid; uuid=$(uuidgen "$@") || return $?
  if [[ -t 1 && $uuid != *Usage* ]]; then
    xsel -bi --trim <<<"$uuid"
    printf '%s \e[1;3;30m(copied)\e[m\n' "$uuid"
  else
    echo "$uuid"
  fi
}

# For dry runs / printing arrays
q() { printf '%q ' "$@"; printf '\n'; }
n() { printf '%s\n' "$@"; }

# Load mods
for mod in ~/.config/bashrc.d/*.sh; do
  # shellcheck disable=SC1090
  . "$mod"
done
