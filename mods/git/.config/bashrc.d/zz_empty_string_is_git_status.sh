# Copyright (c) Max Kagamine
# Licensed under the Apache License, Version 2.0
#
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

  jobs -l >/dev/null # Fixes starship bug https://github.com/starship/starship/issues/3096#issuecomment-988527867
}

if [[ "${precmd_functions[*]}" != *precmd_empty_string_alias* ]]; then
  precmd_functions+=(precmd_empty_string_alias)
fi
