# shellcheck shell=bash

alias ni='npm i'
alias nid='ni -D'
alias nu='npm un'
alias nud='nu -D'

alias nr='npm run'
alias nrb='nr build'
alias nrw='nr watch'
alias ns='npm start'
alias nt='npm test'

alias nir='ni && nr'
alias nirb='ni && nrb'
alias nirw='ni && nrw'
alias nis='ni && ns'

alias nc='npx npm-check -su'

# Possibly more secure than adding to PATH, but more importantly it suppresses
# the warning from 'find' when using -execdir
command_not_found_handle() {
  if [[ -x "./node_modules/.bin/$1" ]]; then
    "./node_modules/.bin/$1" "${@:2}"
  elif [[ -x /usr/lib/command-not-found ]]; then # Ubuntu
    /usr/lib/command-not-found -- "$1"
  else
    printf -- '-bash: %s: command not found\n' "$1" >&2
    return 127
  fi
}
