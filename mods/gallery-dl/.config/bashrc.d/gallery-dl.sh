# shellcheck shell=bash

alias gal='gallery-dl'

. /usr/share/bash-completion/completions/gallery-dl
complete -F _gallery_dl gal
