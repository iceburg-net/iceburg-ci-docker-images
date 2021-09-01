#!/usr/bin/env bash
set -eo pipefail
PROJECT_HOME="${PROJECT_HOME:-$( cd "$(dirname "$0")/.."; pwd -P)}"
cd "$PROJECT_HOME"

for service in $(docker-compose config --services); do
  docker-compose run --rm "$service"
done
