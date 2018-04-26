#!/bin/bash
set -e

# Adapted from https://gist.github.com/vitalk/8639831

branch="$(git rev-parse --abbrev-ref HEAD)"

{
    git for-each-ref --format="%(refname:short) %(upstream:short)" refs/heads
    git for-each-ref --format="%(refname:short) %(upstream:short)" refs/remotes
} | \
while read local upstream; do

    # Branch to compare against
    upstream=${1:-master}

    ahead=$(git rev-list ${upstream}..${local} --count)
    behind=$(git rev-list ${local}..${upstream} --count)

    if [[ $local == $branch ]]; then
        asterisk=*
    else
        asterisk=' '
    fi

    # Show asterisk before current branch
    echo -n "$asterisk $local"

    color_ahead="\e[32m"
    color_behind="\e[31m"
    color_reset="\e[0m"

    if [[ $ahead -ne 0 && $behind -ne 0 ]]; then
        echo -ne " ($color_ahead$ahead ahead$color_reset and $color_behind$behind behind$color_reset $upstream)"
    elif [[ $ahead -ne 0 ]]; then
        echo -ne " ($color_ahead$ahead ahead$color_reset $upstream)"
    elif [[ $behind -ne 0 ]]; then
        echo -ne " ($color_behind$behind behind$color_reset $upstream)"
    fi

    echo

done
