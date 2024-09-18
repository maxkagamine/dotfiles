# shellcheck shell=bash

alias mad='mkanimedir'
alias mar='mkanimereadme'
alias mmd='mkmoviedir'
alias up='upscale'

complete -f -W '
  --all
  --waifu2x
  --cugan
  --esrgan
  --auto
  -s
  -n
  -f
  --histmatch
  --dry-run
  --verbose
  -h --help
' upscale up

complete -d -W '
  -p --prefix
  -s --suffix
  -d --delimiter
  -n --dry-run
  -h --help
' flatten

complete -f -d -W '
  -z
  --si
  --paths-from-stdin
  -h --help
' weigh
