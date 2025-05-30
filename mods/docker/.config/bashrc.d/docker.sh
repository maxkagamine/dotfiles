# shellcheck shell=bash

alias d='docker'
alias dr='d run -it --rm'
alias dx='d exec -it'
alias dc='d compose'
alias dcu='dc up --wait'
alias dcd='dc down'
alias dcr='dcu --build --force-recreate --remove-orphans'

ds() { # "docker status"
  docker ps -a; echo
  if command -v unbuffer &>/dev/null; then
    unbuffer docker image ls --tree | grep -Pv '^$|WARNING:'
  else
    docker image ls --tree
  fi
}

# https://github.com/maxkagamine/sqlarserver
alias sqlarserver='dr -v .:/srv:ro -p 3939:80 -e TZ=Asia/Tokyo kagamine/sqlarserver'
alias sqlarserverd='dr -d -v .:/srv:ro -p 3939:80 -e TZ=Asia/Tokyo --name=sqlarserver kagamine/sqlarserver'

# https://github.com/alexheretic/ab-av1 (image must be built locally)
alias ab-av1='dr -v .:/videos -v ab-av1:/root/.cache/ab-av1 ab-av1'

# https://github.com/w3c/epubcheck (image must be built locally)
alias epubcheck='dr -v .:/data:ro epubcheck'

# https://github.com/apngasm/apngasm (custom dockerfile)
alias apngasm='dr -v .:/srv apngasm'

# https://github.com/wagoodman/dive
if ! command -v dive &>/dev/null; then
  alias dive='dr -v /var/run/docker.sock:/var/run/docker.sock:ro -v ~/.config/dive/dive.yml:/root/.dive.yml wagoodman/dive'
fi
