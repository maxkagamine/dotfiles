# Copyright (c) Max Kagamine
# Licensed under the Apache License, Version 2.0
#
# shellcheck shell=bash

# TODO: Install ab-av1 automatically from AUR.
# Also requires vmaf-git from AUR:
# https://github.com/alexheretic/ab-av1/issues/374#issuecomment-5245398705

# HEVC encoder version 4.3
# SVT-AV1 Encoder Lib v4.2.0
#
# encoder     | time       | vmaf     | size
# ----------- | ---------- | -------- | -----------------
# x265 medium |  9m19.178s | 95.93453 | 1191.42 MiB (76%)
# x265 slow   | 23m11.684s | 95.85429 | 1069.56 MiB (68%)
# svt-av1 4   |  5m18.855s | 95.71334 |  835.20 MiB (53%)
# svt-av1 3   |  9m29.622s | 95.65219 |  833.73 MiB (53%)
# svt-av1 2   | 16m54.374s | 95.74332 |  837.27 MiB (53%)
# svt-av1 1   | 34m06.570s | 95.80672 |  909.10 MiB (58%)

_AB_VMAF_ARGS='--vmaf model=version=vmaf_v1.0.16_1d5h_2160'

_AB_BASE_ARGS="$_AB_VMAF_ARGS \
  -v \
  --min-vmaf 95 \
  --thorough \
  --min-samples 6"

_AB_HEVC_ARGS="$_AB_BASE_ARGS \
  -e libx265 \
  --pix-format yuv420p10le \
  --preset slow \
  --min-crf 6 \
  --max-crf 30"

# ab-av1 by default sets keyint to 10s for videos >3m. This causes noticeable
# seek lag in players configured for exact (rather than keyframe) seeking, even
# with hardware decoding (with software decoding it's awful). -1 is the default
# value of the -g option in ffmpeg (libavcodec), i.e. the same as not specifying
# -g at all, and causes libsvtav1 to use its own default which is 5s rounded to
# the nearest "mini-GOP" for efficiency (the "2-3s" mentioned in ffmpeg's docs
# appears to be outdated).
_AB_AV1_ARGS="$_AB_BASE_ARGS \
  --preset 4 \
  --keyint=-1"

alias ab-vmaf="ab-av1 vmaf $_AB_VMAF_ARGS"
alias ab-crf-hevc="ab-av1 crf-search $_AB_HEVC_ARGS"
alias ab-crf-av1="ab-av1 crf-search $_AB_AV1_ARGS"
alias ab-encode-hevc="ab-av1 auto-encode $_AB_HEVC_ARGS"
alias ab-encode-av1="ab-av1 auto-encode $_AB_AV1_ARGS"

unset _AB_VMAF_ARGS _AB_BASE_ARGS _AB_HEVC_ARGS _AB_AV1_ARGS

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
' ab-crf-hevc ab-crf-av1 ab-encode-hevc ab-encode-av1
