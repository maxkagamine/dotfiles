# shellcheck shell=bash

. /usr/share/doc/fzf/examples/key-bindings.bash

export FZF_CTRL_T_OPTS='--ansi'
export FZF_CTRL_T_COMMAND='fd --hidden --exclude .git --color always .'

export FZF_ALT_C_OPTS=$FZF_CTRL_T_OPTS
export FZF_ALT_C_COMMAND="$FZF_CTRL_T_COMMAND --type d"
