# shellcheck shell=bash disable=SC2120,SC2119

CDPATH='.:/mnt/user:/mnt/user/Docker:/mnt:/boot/config/plugins/user.scripts/scripts'

open-files() { # [-f [<delay>]]
  local output pids
  if [[ $1 == '-f' ]]; then
    while output=$(open-files); do
      printf '\ec%s\n' "$output"
      sleep "${2:-3}"
    done
    return
  fi
  if ! pids=$(pgrep 'smbd|shfs' | paste -sd, -); then
    echo 'No smbd or shfs processes running.' >&2
    return 1
  fi
  lsof -p "$pids" |
    awk 'match($0, / REG .* (\/mnt\/.*)/, x) && ! /Docker/ { print x[1] }'
}
