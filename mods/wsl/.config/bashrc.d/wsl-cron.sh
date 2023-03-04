# shellcheck shell=bash
( service cron status || sudo service cron start & ) >/dev/null
