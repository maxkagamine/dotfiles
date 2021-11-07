# shellcheck shell=bash
#
# Alias empty string to `git status` when in git repo.
# HISTCONTROL must not have ignoredups or ignoreboth.

_ps1_empty_string_alias() {
  "$@"

  _LAST="$(history 1)"
  if [[ "$_LAST" == "$_LAST2" ]] &&
    git rev-parse --is-inside-work-tree &>/dev/null; then
    git status
  fi
  _LAST2="$_LAST"
}

PROMPT_COMMAND="_ps1_empty_string_alias $PROMPT_COMMAND"
