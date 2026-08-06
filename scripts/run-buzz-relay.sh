#!/usr/bin/env bash
set -euo pipefail

cd /home/gifma/projects/buzz
set -a
source .env
set +a
exec ./target/debug/buzz-relay
