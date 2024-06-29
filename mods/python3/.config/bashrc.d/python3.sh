# shellcheck shell=bash disable=SC1091

alias py='python3'
alias pir='pip install -r requirements.txt'

pi() {
  pip install "$@" || return $?
  if [[ -f requirements.txt ]]; then
    pip freeze | grep -Pi "$(IFS='|'; printf '^(%s)==' "$*")" >> requirements.txt
  fi
}

venv() {
  local fullPath
  case $1 in
    init)
      python3 -m venv "${2:-.venv}" && . "${2:-.venv}"/bin/activate
      ;;
    upgrade)
      python3 -m venv --upgrade --upgrade-deps "${2:-.venv}"
      ;;
    destroy)
      fullPath=$(realpath "${2:-.venv}")
      if [[ ! -f "$fullPath/pyvenv.cfg" ]]; then
        printf "'%s' does not exist or is not a venv.\n" "$fullPath" >&2
        return 1
      fi
      if [[ $VIRTUAL_ENV == "$fullPath" ]]; then
        deactivate
      fi
      rm -rf "$fullPath"
      ;;
    deactivate)
      deactivate
      ;;
    activate)
      shift
      ;& # Fall through
    *)
      fullPath=$(realpath "${1:-.venv}")
      if [[ -f "$fullPath"/bin/activate ]]; then
        . "$fullPath"/bin/activate
      elif [[ -f "$fullPath"/Scripts/activate ]]; then
        # Created with Windows python, which means it contains CRLFs and Windows
        # paths… Why does python create a bash script that can't be run in bash?
        eval "$(tr -d $'\r' <"$fullPath"/Scripts/activate |
          awk -v venv="$(printf '%q' "$fullPath")" \
            '/^VIRTUAL_ENV=/ { print "VIRTUAL_ENV=" venv; next } { print }')"
        # We also need to create symlinks without the .exe extension
        local exe shim
        for exe in "$fullPath"/Scripts/*.exe; do
          chmod +x "$exe"
          shim=${exe%.exe}
          if [[ ! -f $shim ]]; then
            ln -sfv "$(basename "$exe")" "$shim" | sed 's/^/Creating symlink: /'
          fi
          # Also for python3, for which it doesn't create an exe
          if [[ $exe == */python.exe && ! -f "$fullPath"/Scripts/python3.exe && ! -f "$fullPath"/Scripts/python3 ]]; then
            ln -sfv python.exe "$fullPath"/Scripts/python3 | sed 's/^/Creating symlink: /'
          fi
        done
      elif [[ ! -f "$fullPath/pyvenv.cfg" ]]; then
        printf "'%s' does not exist or is not a venv.\n" "$fullPath" >&2
        return 1
      else
        # May have been initially created with --upgrade, which doesn't seem to
        # create the necessary scripts (probably a bug in the venv module)
        printf "'%s' is missing activate script.\n" "$fullPath" >&2
        return 1
      fi
      ;;
  esac
}

complete -dW 'init upgrade destroy deactivate activate' venv
