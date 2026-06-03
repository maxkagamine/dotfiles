# Copyright (c) Max Kagamine
# Licensed under the Apache License, Version 2.0
#
# shellcheck shell=bash

export DOTNET_CLI_TELEMETRY_OPTOUT=1

_dotnet_bash_complete() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local candidates
  read -d '' -ra candidates < <(dotnet complete --position "$COMP_POINT" "$COMP_LINE" 2>/dev/null || true)
  read -d '' -ra COMPREPLY < <(compgen -W "${candidates[*]:-}" -- "$cur" || true)
}

complete -f -F _dotnet_bash_complete dotnet dotnet.exe
