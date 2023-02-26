# shellcheck shell=bash

eval "$(ab-av1 print-completions)"

alias av1='ab-av1'
complete -F _ab-av1 -o bashdefault -o default av1
