# shellcheck shell=bash

alias d='docker'
alias dr='d run -it --rm'
alias dx='d exec -it'
alias dc='d compose'
alias dcu='dc up --wait'
alias dcd='dc down'
alias dcr='dcu --build --force-recreate --remove-orphans'

ds() { # docker status
  {
    docker ps -a || return $?
    echo
    if command -v unbuffer &>/dev/null; then
      unbuffer docker image ls --tree |
        sed '/IMAGE/,$!d' |
        awk '
          function complete_last_image() {
            if (buffer == "") {
              return;
            }
            if (gsub(/\033\[39m[├└]/, "&", buffer) > 1) {
              sub(/\n$/, "", buffer);
              images[i++] = buffer;
            } else {
              split(buffer, lines, "\n");
              images[i++] = lines[1];
            }
            buffer = "";
          }
          NR == 1 { print; next; }
          /^\033\[34m\033\[1m/ { complete_last_image(); }
          /^\033\[34m\033\[1m|^\033\[39m/ { buffer = buffer $0 "\n"; }
          END {
            complete_last_image();
            asort(images);
            for (i in images) {
              print images[i];
            }
          }
        '
    else
      docker image ls
    fi
  } | less
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
