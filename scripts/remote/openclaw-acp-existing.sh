#!/bin/sh
set -eu

exec docker compose \
  --project-directory /docker/openclaw-kv6w \
  -f /docker/openclaw-kv6w/docker-compose.yml \
  exec -T --user node --workdir /home/node/openclaw \
  openclaw openclaw acp --url ws://127.0.0.1:62829
