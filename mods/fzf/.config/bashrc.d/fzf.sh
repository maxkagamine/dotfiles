# shellcheck shell=bash

. /usr/share/fzf/key-bindings.bash

# First Ctrl+T shows contents of current dir; pressing again recurses
export FZF_CTRL_T_OPTS="
  --ansi
  --bind 'ctrl-t:reload(fd --hidden --exclude .git --color always .)'
"
export FZF_CTRL_T_COMMAND='ls -vAN --color=always --group-directories-first'

export FZF_ALT_C_OPTS=$FZF_CTRL_T_OPTS
export FZF_ALT_C_COMMAND="$FZF_CTRL_T_COMMAND --type d"
