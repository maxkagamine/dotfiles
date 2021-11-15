# shellcheck shell=bash

. /usr/share/doc/fzf/examples/key-bindings.bash

alias 🦇='batview'

export BAT_THEME='OneHalfDark'
export BAT_STYLE='numbers,changes'

export FZF_CTRL_T_OPTS="--ansi --preview 'BAT_STYLE=plain batview {} | head -500'"
export FZF_CTRL_T_COMMAND='fd --hidden --exclude .git --color always .'

export FZF_ALT_C_OPTS=$FZF_CTRL_T_OPTS
export FZF_ALT_C_COMMAND="$FZF_CTRL_T_COMMAND --type d"
