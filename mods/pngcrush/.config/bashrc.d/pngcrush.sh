# Copyright (c) Max Kagamine
# Licensed under the Apache License, Version 2.0
#
# shellcheck shell=bash

pngcrush() (
  set -e
  for f in "$@"; do
    command pngcrush -brute -ow "$f" "$f.tmp"
  done
)
