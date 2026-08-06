#!/bin/sh
set -eu

exec docker compose \
  --project-directory /root/hermes-docker \
  -f /root/hermes-docker/docker-compose.yml \
  -f /root/hermes-docker/docker-compose.override.yml \
  exec -T --user hermes --workdir /opt/data \
  hermes /opt/data/.local/bin/hermes acp
