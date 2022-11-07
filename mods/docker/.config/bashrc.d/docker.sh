# shellcheck shell=bash

alias d='docker'
alias dr='docker run -it --rm'
alias dx='docker exec -it'
alias dc='docker compose'

ctop() {
  docker run --rm -it \
    --name=ctop \
    --volume /var/run/docker.sock:/var/run/docker.sock:ro \
    quay.io/vektorlab/ctop:latest
}

runlike() {
  if (( $# == 0 )); then
    docker ps --format '{{.Names}}' |
      fzf --preview 'runlike {} --color=always' --preview-window 'right:66%' |
      xargs -rI {} bash -c "runlike '{}'"
  else
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock:ro \
      assaflavie/runlike -p "$1" |
      sed -E 's/^\s+/  /' |
      bat -pp -l sh "${@:2}"
  fi
}

export -f runlike # Makes the function available in fzf --preview and xargs
