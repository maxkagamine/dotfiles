# shellcheck shell=bash
#
# Alias empty string to `git status` when in git repo.
# HISTCONTROL must not have ignoredups or ignoreboth.

unset HISTCONTROL

precmd_empty_string_alias() {
  _LAST="$(history 1)"
  if [[ "$_LAST" == "$_LAST2" ]] &&
    git rev-parse --is-inside-work-tree &>/dev/null; then
    git status
  fi
  _LAST2="$_LAST"
}

precmd_functions+=(precmd_empty_string_alias)
