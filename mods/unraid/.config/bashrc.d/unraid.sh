# shellcheck shell=bash

CDPATH='.:/mnt/user:/mnt/user/Docker:/mnt'

fix() {
  chown -R nobody:users "$@"
  chmod -R a+rw "$@"
}
