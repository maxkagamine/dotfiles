# Copyright (c) Max Kagamine
# Licensed under the Apache License, Version 2.0
#
# shellcheck shell=bash

alias gal='gallery-dl'

# Completions
#
#   git clone --depth 1 https://codeberg.org/mikf/gallery-dl.git
#   cd gallery-dl
#   make data/completion/gallery-dl
#
# shellcheck disable=SC2207
_gallery_dl() {
  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  if [[ "${prev}" =~ ^(-i|--input-file|-I|--input-file-comment|-x|--input-file-delete|-e|--error-file|--write-log|--write-unsupported|-c|--config|--config-json|--config-yaml|--config-toml|-C|--cookies|--cookies-export|--download-archive)$ ]]; then
    COMPREPLY=( $(compgen -f -- "${cur}") )
  elif [[ "${prev}" =~ ^()$ ]]; then
    COMPREPLY=( $(compgen -d -- "${cur}") )
  else
    COMPREPLY=( $(compgen -W "--help --version --filename --destination --directory --restrict-filenames --windows-filenames --extractors --compat --server --update-check --input-file --input-file-comment --input-file-delete --no-input --quiet --warning --verbose --get-urls --resolve-urls --dump-json --resolve-json --simulate --extractor-info --list-keywords --error-file --print --Print --print-to-file --Print-to-file --list-modules --list-extractors --write-log --write-unsupported --write-pages --print-traffic --no-colors --retries --user-agent --http-timeout --proxy --xff --source-address --force-ipv4 --force-ipv6 --no-check-certificate --limit-rate --chunk-size --no-part --no-skip --no-mtime --no-download --sleep --sleep-skip --sleep-extractor --sleep-request --sleep-retries --sleep-429 --option --config --config-json --config-yaml --config-toml --config-type --config-ignore --ignore-config --config-create --config-status --config-open --cache-file --cache-status --cache-show --cache-clear --cache-vacuum --clear-cache --username --password --netrc --cookies --cookies-export --cookies-from-browser --abort --terminate --filesize-min --filesize-max --download-archive --date-before --date-after --blacklist --whitelist --tags-blacklist --tags-whitelist --range --post-range --child-range --filter --post-filter --child-filter --file-range --image-range --chapter-range --file-filter --image-filter --chapter-filter --postprocessor --no-postprocessors --postprocessor-option --write-metadata --write-info-json --write-infojson --write-tags --zip --cbz --mtime --mtime-from-date --rename --rename-to --ugoira --ugoira-conv --ugoira-conv-lossless --ugoira-conv-copy --exec --exec-after" -- "${cur}") )
  fi
}

complete -F _gallery_dl gallery-dl
complete -F _gallery_dl gal
