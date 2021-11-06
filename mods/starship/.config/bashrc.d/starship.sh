# shellcheck shell=bash disable=SC2034

eval "$(starship init bash)"

_starship_precmd_user_func(){
  local dir=${PWD##*/}
  [[ $PWD == "$HOME" ]] && dir='~'
  echo -ne "\e]0;${dir}\a"
}

starship_precmd_user_func='_starship_precmd_user_func'
