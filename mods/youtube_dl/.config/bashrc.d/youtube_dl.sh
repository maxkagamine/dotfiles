# shellcheck shell=bash

alias yt='youtube-dl'

# '!=economy' prevents downloading niconico's low quality, high traffic mode videos
alias ytmp3='yt -xf "(bestaudio/best)[format_id!=economy]" --audio-format mp3 --audio-quality 0'
