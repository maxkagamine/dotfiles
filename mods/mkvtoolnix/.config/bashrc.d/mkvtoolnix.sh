# Copyright (c) Max Kagamine
# Licensed under the Apache License, Version 2.0
#
# shellcheck shell=bash

alias mkv-bat='mkv-batch'

complete -f -W '
  -a --audio-tracks
  -d --video-tracks
  -s --subtitle-tracks
  -m --attachments
  -A --no-audio
  -D --no-video
  -S --no-subtitles
  -M --no-attachments
  --track-order
  --default-track-flag
  --forced-display-flag
  --track-name
  --language
  --title
' mkv-batch mkv-bat

complete -f -W '--no-sort' mkv-cat
complete -f -W '-n' mkv-extract-fonts
complete -f -W '-l -n' mkv-extract-subs
complete -f -W '-a --attachments' mkv-ls
