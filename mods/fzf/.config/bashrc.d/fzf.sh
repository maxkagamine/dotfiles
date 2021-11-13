# shellcheck shell=bash disable=SC1091

. /usr/share/doc/fzf/examples/key-bindings.bash

if command -v source-highlight &>/dev/null; then
  export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
fi

export FZF_CTRL_T_OPTS="--ansi --preview '( [[ -d {} ]] && ${BASH_ALIASES[ls]} -x --color=always {} || less -RX {} ) | head -200'"
export FZF_CTRL_T_COMMAND='fd --hidden --exclude .git --color always .'
export FZF_ALT_C_OPTS=$FZF_CTRL_T_OPTS
export FZF_ALT_C_COMMAND="$FZF_CTRL_T_COMMAND --type d"
