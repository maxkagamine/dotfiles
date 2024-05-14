# shellcheck shell=bash

alias d='docker'
alias dr='d run -it --rm'
alias dx='d exec -it'
alias dc='d compose'
alias dps='d ps -a' # docker container ls -a
alias dis='d images -a' # docker image ls -a
alias dcu='dc up --wait'
alias dcd='dc down'
alias dcr='dcu --build --force-recreate --remove-orphans'

# https://github.com/alexheretic/ab-av1 (image must be built locally)
alias ab-av1='dr -v .:/videos -v ab-av1:/root/.cache/ab-av1 ab-av1'

# https://github.com/w3c/epubcheck (image must be built locally)
alias epubcheck='dr -v .:/data:ro epubcheck'

# https://github.com/wagoodman/dive
alias dive='dr -v /var/run/docker.sock:/var/run/docker.sock:ro wagoodman/dive'
