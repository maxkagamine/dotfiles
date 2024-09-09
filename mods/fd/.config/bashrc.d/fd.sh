# shellcheck shell=bash

alias todos='fdgrep -F TODO'

fdgrep() {
  if [[ $# == 0 || $1 =~ ^(--help|-h)$ ]]; then
    cat >&2 <<EOF
Usage: fdgrep [<grep opts>] <pattern> [<fd opts>]

Leverages fd for faster recursive grepping & gitignore exclusion (-I to fd to
disable gitignore, -H to include hidden files, -u for both).
EOF
    return 1
  fi
  local grep_opts=()
  if [[ -t 1 ]]; then
    grep_opts+=(--color=always)
  fi
  while (( $# > 0 )); do
    grep_opts+=("$1")
    if [[ $1 != -* ]]; then
      shift
      break
    fi
    shift
  done
  fd -tf "$@" -X grep "${grep_opts[@]}"
}
