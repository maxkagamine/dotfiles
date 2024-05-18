# shellcheck shell=bash disable=SC2120,SC2119

CDPATH='.:/mnt/user:/mnt/user/Docker:/mnt:/boot/config/plugins/user.scripts/scripts'

open-files() { # [-f [<delay>]]
  if [[ $1 == '-f' ]]; then
    local output
    while output=$(open-files); do
      printf '\ec%s\n' "$output"
      sleep "${2:-3}"
    done
    return
  fi
  lsof -p "$(pgrep 'smbd|shfs' | paste -sd, -)" |
    awk 'match($0, / REG .* (\/mnt\/.*)/, x) && ! /Docker/ { print x[1] }'
}
