# Copyright (c) Max Kagamine
# Licensed under the Apache License, Version 2.0
#
# shellcheck shell=bash

alias ni='npm i'
alias nid='ni -D'
alias nu='npm un'
alias nud='nu -D'

alias nr='npm run'
alias nrb='nr build'
alias nrw='nr watch'
alias ns='npm start'
alias nt='npm test'

alias nir='ni && nr'
alias nirb='ni && nrb'
alias nirw='ni && nrw'
alias nis='ni && ns'

alias nc='npx npm-check -su'

# Disable punycode deprecation & --experimental-strip-types warnings
export NODE_OPTIONS='--disable-warning=DEP0040 --disable-warning=ExperimentalWarning'
