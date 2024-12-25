# shellcheck shell=bash disable=SC2034,SC2154

if [[ ${preexec_functions[*]} != *starship* ]]; then
  eval "$(starship init bash)"
fi

_starship_precmd_user_func() {
  local dir=${PWD##*/}
  [[ $PWD == "$HOME" ]] && dir='~'
  echo -ne "\e]0;${dir}\a"
}

starship_precmd_user_func='_starship_precmd_user_func'
