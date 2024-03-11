# shellcheck shell=bash

alias up='upscale'

complete -f -W '--all --waifu2x --cugan --esrgan --auto -s -n -f --histmatch --dry-run --verbose' upscale up
