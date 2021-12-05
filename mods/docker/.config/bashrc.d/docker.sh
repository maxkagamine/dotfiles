# shellcheck shell=bash

alias d='docker'
alias dr='docker run -it --rm'
alias dx='docker exec -it'

dc() {
  if (( $# > 0 )); then
    docker container "$@"
  else
    # Inspired by https://github.com/politeauthority/docker-pretty-ps
    docker container ls -a --no-trunc --format "{{.State}} {{.Names}}
ID:        {{.ID}}
Image:     {{.Image}}
Status:    {{.Status}}
Network:   {{.Networks}}
Ports:     {{.Ports}}
Mounts:    {{.Mounts}}
" | \
    perl -p0e '
      s/^running (.*)/\e[32m● \1\e[m/gm;
      s/^exited (.*?\n\n)/\e[1;30m● \1\e[m/gsm;
      s/^\w+: *\n//gsm;
      s/, ?/\n           /g;
      s/^(ID:\s+\w{12}).*/\1/gm;
    ' | \
    head -n -1
  fi
}

di() {
  if (( $# > 0 )); then
    docker image "$@"
  else
    docker image ls
  fi
}
