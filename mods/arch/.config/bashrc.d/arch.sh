# Copyright (c) Max Kagamine
# Licensed under the Apache License, Version 2.0
#
# shellcheck shell=bash

# Usage: pacwhy <package>
#
# Colorizes pactree -r's output based on whether each package was explicitly
# installed or installed as a dependency of another package.
pacwhy() {
  local explicit deps
  explicit=$(pacman -Qe | awk '{ print $1 }' | paste -sd'|')
  deps=$(pacman -Qd | awk '{ print $1 }' | paste -sd'|')
  pactree -r "$1" | \
    perl -pe 's/(?<=^|─)('"$explicit"')$/\e[32m$1\e[m/; s/(?<=^|─)('"$deps"')$/\e[36m$1\e[m/'
}

# Usage: pacwhich <command>
#
# Shows which package provides a command.
pacwhich() {
  local path
  path=$(which "$1")
  pacman -Qo "$path"
}

# Shows explicitly-installed packages that aren't in these Makefiles.
#
# To show details: pacwtf | xx pacman -Qi
pacwtf() {
  local installed listed
  installed=$(pacman -Qe | cut -d' ' -f1 | sort)
  listed=$( {
    fd 'Makefile' "$DOTFILES_DIR" -X grep -Poh \
      '(?<=\$\(PACMAN\) |MISC_UTILS_PACKAGES\+=).*' | grep -vF '$' | tr ' ' $'\n'

    echo 'stow'
    echo 'libnvidia-container' # See docker mod
    echo 'nvidia-container-toolkit' # See docker mod
  } | sort -u)

  comm -23 <(echo "$installed") <(echo "$listed")
}

__pacwhy() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  local pkgs; pkgs=$(pacman -Q | awk '{ print $1 }')
  # shellcheck disable=SC2312
  readarray -t COMPREPLY < <(compgen -W "$pkgs" -- "$cur")
}

complete -F __pacwhy pacwhy
complete -c pacwhich
