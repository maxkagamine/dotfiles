# shellcheck shell=bash

# OCI container format doesn't support "HEALTHCHECK"
export BUILDAH_FORMAT=docker

# Override alias in docker.sh; podman-compose doesn't support --wait
# https://github.com/containers/podman-compose/issues/710
alias dcu='dc up'
