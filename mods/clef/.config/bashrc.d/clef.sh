# shellcheck shell=bash

clef() {
  local opts=(-i "$1")
  if [[ $2 ]]; then
    opts+=(--filter "$2")
  fi
  if [[ $TEMPLATE ]]; then
    opts+=(--format-template "$TEMPLATE")
  else
    opts+=(--format-template '[{@t:HH:mm:ss} {@l:u3}] {@m}{NewLine()}{@x}')
  fi
  # unbuffer connects the command to a pty to make it think its stdout isn't
  # redirected, which is meant to prevent commands from buffering their outputs
  # but is helpful here to keep it from disabling color when piping to less
  unbuffer clef "${opts[@]}" | less
}

alias cleff='TEMPLATE="[{@t:o} {@l:u3}] {@m} {Rest(true)}{NewLine()}{@x}" clef'
