# Copyright (c) Max Kagamine
# Licensed under the Apache License, Version 2.0
#
# shellcheck shell=bash disable=SC1091

alias py='python3'
alias pir='pip install -r requirements.txt'
alias pipdeptree='pipdeptree --python=auto'
alias serve='python -m http.server -b 127.0.0.1'

pi() {
  pip install "$@" || return
  if [[ -f requirements.txt ]]; then
    pip freeze | grep -Pi "$(IFS='|'; printf '^(%s)==' "$*")" >> requirements.txt
  fi
}

venv() {
  local full_path activate_script
  case $1 in
    init)
      python3 -m venv "${2:-.venv}" && . "${2:-.venv}"/bin/activate
      ;;
    upgrade)
      python3 -m venv --upgrade --upgrade-deps "${2:-.venv}"
      ;;
    destroy)
      full_path=$(realpath "${2:-.venv}")
      if [[ ! -f "$full_path/pyvenv.cfg" ]]; then
        printf "'%s' does not exist or is not a venv.\n" "$full_path" >&2
        return 1
      fi
      if [[ $VIRTUAL_ENV == "$full_path" ]]; then
        deactivate
      fi
      rm -rf "$full_path"
      ;;
    deactivate)
      deactivate
      ;;
    activate)
      shift
      ;& # Fall through
    *)
      full_path=$(realpath "${1:-.venv}")
      if [[ -f "$full_path"/bin/activate ]]; then
        . "$full_path"/bin/activate
      elif [[ -f "$full_path"/Scripts/activate ]]; then
        # Created with Windows python, which means it contains CRLFs and Windows
        # paths... why does python create a bash script that can't run in bash?
        activate_script=$(
          tr -d $'\r' <"$full_path"/Scripts/activate |
          awk -v venv="$(printf '%q' "$full_path")" \
            '/^VIRTUAL_ENV=/ { print "VIRTUAL_ENV=" venv; next } { print }')
        eval "$activate_script"
        # We also need to create symlinks without the .exe extension
        local exe shim
        for exe in "$full_path"/Scripts/*.exe; do
          chmod +x "$exe"
          shim=${exe%.exe}
          if [[ ! -f $shim ]]; then
            ln -sfv "$(basename "$exe")" "$shim" | sed 's/^/Creating symlink: /'
          fi
          # Also for python3, for which it doesn't create an exe
          if [[ $exe == */python.exe && ! -f "$full_path"/Scripts/python3.exe && ! -f "$full_path"/Scripts/python3 ]]; then
            ln -sfv python.exe "$full_path"/Scripts/python3 | sed 's/^/Creating symlink: /'
          fi
        done
      elif [[ ! -f "$full_path/pyvenv.cfg" ]]; then
        printf "'%s' does not exist or is not a venv.\n" "$full_path" >&2
        return 1
      else
        # May have been initially created with --upgrade, which doesn't seem to
        # create the necessary scripts (probably a bug in the venv module)
        printf "'%s' is missing activate script.\n" "$full_path" >&2
        return 1
      fi
      ;;
  esac
}

complete -dW 'init upgrade destroy deactivate activate' venv
