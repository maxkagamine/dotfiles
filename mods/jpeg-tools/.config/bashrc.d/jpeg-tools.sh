# Copyright (c) Max Kagamine
# Licensed under the Apache License, Version 2.0
#
# shellcheck shell=bash

alias jpegtran='jpegtran -perfect -optimize -strict'

jpegli() { # <image>...
  local f out
  for f; do
    out="${f%.*}.jpg"
    if [[ -f $out ]]; then
      out="${f%.*}.jpegli.jpg"
    fi
    cjpegli "$f" "$out" || return
    echo "Wrote $out"
  done
}
