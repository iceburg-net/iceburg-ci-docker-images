#!/usr/bin/env bash
set -eo pipefail
log(){ printf "[%-5s%s minimal-image] $*\\n" "${__ll:-INFO}" >&2; }
die(){ __ll=ERROR log "$*"; exit 1; }

log "testing coming soon"
