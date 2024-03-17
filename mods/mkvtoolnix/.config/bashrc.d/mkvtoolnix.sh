# shellcheck shell=bash

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
' mkv-batch

complete -f -W '--no-sort' mkv-cat
complete -f -W '-n' mkv-extract-fonts
complete -f -W '-l -n' mkv-extract-subs
complete -f -W '-a --attachments' mkv-ls
