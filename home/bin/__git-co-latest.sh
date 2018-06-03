#!/usr/bin/env bash
set -e

if [[ $# != 1 ]]; then
	echo 'Usage: git co-latest <branch>' >&2
	echo 'Pulls the local branch before checking it out. Useful to avoid' >&2
	echo 'rolling back a large number of changes before getting latest.' >&2
	exit 1
fi

if upstream=$(git rev-parse --abbrev-ref "$1@{upstream}"); then
	git fetch "${upstream%%/*}" "${upstream#*/}:$1"
	git checkout "$1"
fi
