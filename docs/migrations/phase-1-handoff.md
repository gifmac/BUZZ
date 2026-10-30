# Phase one handoff

## Completed state

- Buzz `desktop-v0.5.3` at commit
  `3a96acea09b4a9e3f02c3a26cfb0607d2ccacf42` is pinned and built in Ubuntu
  WSL2.
- Local dependencies are healthy on dedicated loopback ports.
- The relay remains bound to `127.0.0.1:13000` and is externally reachable at
  `wss://buzz.proeduconnect.com` through the approved pre-existing Windows
  Cloudflare Tunnel.
- Buzz Desktop 0.5.3 is installed and running for the current Windows user.
- The desktop launcher injects the public pilot relay URL and Git Bash path.
- Public NIP-11, WSS/NIP-42 challenge, and signed create/get/delete verification
  passed. Readiness, liveness, and metrics paths return HTTP 404 publicly.
- No new named tunnel, Cloudflare Access policy, service token, persistent agent
  key, or VPS change has been made.

## Next approval gate

Before either remote agent is changed, present the exact Hermes/OpenClaw config
diff, secret placement, service impact, rollback commands, and WSS verification
steps.

Only the relay origin may appear in Cloudflare ingress. PostgreSQL, Redis,
MinIO, Adminer, Keycloak, Prometheus, Git storage, health, metrics, and dev
ports remain excluded.

Do not switch to the production Compose bundle while upstream issue #2814 is
open unless a separately reviewed fresh-volume ownership validation and
rollback test are approved.