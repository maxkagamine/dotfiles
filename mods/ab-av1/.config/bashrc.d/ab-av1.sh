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

complete -f -W '--reference --distorted' ab-vmaf
complete -f -W '
  --acodec
  --and-vmaf
  --cache
  --crf-increment
  --downmix-to-stereo
  --enc
  --enc-input
  --encoder
  --fail-fast
  --help
  --high-crf-means-hq
  --input
  --keep
  --keyint
  --max-crf
  --max-encoded-percent
  --min-crf
  --min-samples
  --min-vmaf
  --min-xpsnr
  --output
  --overwrite-input
  --pix-format
  --preset
  --quiet
  --reference-vfilter
  --sample-duration
  --sample-every
  --samples
  --scd
  --svt
  --temp-dir
  --thorough
  --verbose
  --verify
  --verify-decode
  --verify-duration
  --vfilter
  --video-only
  --vmaf
  --vmaf-fps
  --vmaf-scale
  --xpsnr-fps
  --xpsnr-pix-format
' ab-encode ab-encode-hevc ab-encode-av1
