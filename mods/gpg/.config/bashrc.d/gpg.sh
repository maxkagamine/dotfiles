# shellcheck shell=bash

SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
GPG_TTY=$(tty)
export SSH_AUTH_SOCK GPG_TTY
