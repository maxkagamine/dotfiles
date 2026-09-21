# Copyright (c) Max Kagamine
# Licensed under the Apache License, Version 2.0
#
# shellcheck shell=bash disable=SC2034,SC2154

if [[ ${preexec_functions[*]} != *starship* ]]; then
  eval "$(starship init bash || true)"
fi

_starship_precmd_user_func() {
  # Set window title
  local dir=${PWD##*/}
  [[ $PWD == "$HOME" ]] && dir='~'
  printf '\e]0;%s\a' "$dir"

  # Clear progress bar
  printf '\e]9;4;0;0\e\\'
}

starship_precmd_user_func='_starship_precmd_user_func'
