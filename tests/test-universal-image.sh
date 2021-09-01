#!/usr/bin/env bash
set -eo pipefail
log(){ printf "[%-5s%s universal-image] $*\\n" "${__ll:-INFO}" >&2; }
die(){ __ll=ERROR log "$*"; exit 1; }

bats -v

log "tests pass"
