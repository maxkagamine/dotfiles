# shellcheck shell=bash
. /usr/share/doc/fzf/examples/key-bindings.bash
. /usr/share/doc/fzf/examples/completion.bash

if command -v source-highlight &>/dev/null; then
  export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
fi

export FZF_COMPLETION_OPTS="--ansi --preview '( [[ -d {} ]] && ${BASH_ALIASES[ls]} -x --color=always {} || less -RX {} ) | head -200'"
export FZF_CTRL_T_OPTS=$FZF_COMPLETION_OPTS
export FZF_CTRL_T_COMMAND='_fzf_compgen_path .'
export FZF_ALT_C_OPTS=$FZF_COMPLETION_OPTS
export FZF_ALT_C_COMMAND='_fzf_compgen_dir .'

_fzf_compgen_path() { fd --hidden --exclude .git --color always . "$@"; }
_fzf_compgen_dir() { _fzf_compgen_path "$1" --type d; }
