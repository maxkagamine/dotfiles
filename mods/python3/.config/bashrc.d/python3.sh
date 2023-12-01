# shellcheck shell=bash disable=SC1091

alias py='python3'
alias pi='pip install'
alias pir='pi -r requirements.txt'

venv() {
  case $1 in
    init)
      python3 -m venv .venv && . .venv/bin/activate
      ;;
    upgrade)
      python3 -m venv --upgrade --upgrade-deps .venv
      ;;
    destroy)
      if [[ $VIRTUAL_ENV == "$(realpath .venv)" ]]; then
        deactivate
      fi
      rm -rf .venv
      ;;
    deactivate)
      deactivate
      ;;
    activate|'')
      . .venv/bin/activate
      ;;
  esac
}

complete -W 'init upgrade destroy deactivate activate' venv
