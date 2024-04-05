# shellcheck shell=bash

alias d='docker'
alias dr='docker run -it --rm'
alias dx='docker exec -it'
alias dc='docker compose'
alias dcu='dc up --wait'
alias dcd='dc down'
alias dcr='dcu --build --force-recreate --remove-orphans'

# https://github.com/alexheretic/ab-av1 (image must be built locally)
alias ab-av1='dr -v .:/videos ab-av1'

# https://github.com/w3c/epubcheck (image must be built locally)
alias epubcheck='dr -v .:/data:ro epubcheck'
