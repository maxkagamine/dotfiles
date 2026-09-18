# Copyright (c) Max Kagamine
# Licensed under the Apache License, Version 2.0
#
# shellcheck shell=bash

# TODO: Install ab-av1 automatically from AUR.
# Also requires vmaf-git from AUR:
# https://github.com/alexheretic/ab-av1/issues/374#issuecomment-5245398705

alias ab-vmaf='ab-av1 vmaf --vmaf model=version=vmaf_v1.0.16_1d5h_2160'
alias ab-encode='ab-av1 auto-encode -v \
  --min-vmaf 96 \
  --thorough \
  --min-samples 3 \
  --vmaf model=version=vmaf_v1.0.16_1d5h_2160'
alias ab-encode-hevc='ab-encode -e libx265 --pix-format yuv420p10le --preset slow'
alias ab-encode-av1='ab-encode --preset 3'
