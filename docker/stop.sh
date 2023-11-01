#!/bin/sh

set -a
. ./.env
set +a

docker compose down --remove-orphans