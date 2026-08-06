#!/usr/bin/env bash
set -euo pipefail

relay_pid="$(pgrep -x buzz-relay | head -n 1 || true)"
if [[ -z "$relay_pid" ]]; then
  exit 0
fi

command_line="$(tr '\0' ' ' < "/proc/$relay_pid/cmdline")"
if [[ "$command_line" != *"buzz-relay"* ]]; then
  echo "Refusing to stop unexpected process $relay_pid: $command_line" >&2
  exit 1
fi

kill -TERM "$relay_pid"
