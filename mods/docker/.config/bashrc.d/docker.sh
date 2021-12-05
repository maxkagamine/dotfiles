# shellcheck shell=bash

alias d='docker'
alias dr='docker run -it --rm'
alias dx='docker exec -it'

dc() {
  if (( $# > 0 )); then
    docker container "$@"
  else
    # Inspired by https://github.com/politeauthority/docker-pretty-ps
    docker container ls -a --no-trunc --format "{{.State}} ● {{.Names}}
{{.State}} ID:        {{.ID}}
{{.State}} Image:     {{.Image}}
{{.State}} Status:    {{.Status}}
{{.State}} Network:   {{.Networks}}
{{.State}} Ports:     {{.Ports}}
{{.State}} Mounts:    {{.Mounts}}
" | \
    perl -pe '
      if (/^exited/) {
        s/,\s*/,\e[1;30m/g; # Make sure lists stay colored when split
      }
      s/,\s*/\n           /g;            # Split lists of ports/mounts
      s/^[\w\s]+:\s+\n//m;               # Remove empty lines
      s/(?<=^running )●.*/\e[32m$&\e[m/; # Color name & dot green if running
      s/(?<=^exited ).*/\e[1;30m$&\e[m/; # Fade details of stopped containers
      s/^(running|exited) //;            # Remove statuses used for regex
      s/ID:\s+\w{12}\K\w{52}//;          # Short ids, since --no-trunc was used
    ' | \
    head -n -1 | \
    less -FRX
  fi
}

di() {
  if (( $# > 0 )); then
    docker image "$@"
  else
    docker image ls
  fi
}
