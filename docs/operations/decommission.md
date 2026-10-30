# Buzz pilot decommission

Decommission date: 2026-10-29 (America/New_York)

The Buzz pilot is closed. Every installation it created was removed and this
repository was archived read-only on GitHub. Nothing in this repository is a
live runtime path any more.

## Removed

| Location | Removed |
|---|---|
| Hermes VPS (`srv1069851.hstgr.cloud`) | `buzz-hermes.service` disabled and deleted, `/opt/buzz`, `/etc/buzz` |
| OpenClaw VPS (`srv1161177.hstgr.cloud`) | Nothing to remove; the bridge was never deployed |
| Windows desktop | Buzz Desktop app, Start menu shortcut, uninstall entry |
| Windows AppData | `Local\BuzzPilot` (rollback bundles), `Local\xyz.block.buzz.app`, `Roaming\Buzz`, `Roaming\xyz.block.buzz.app` |
| Docker containers | `buzz-postgres`, `buzz-redis`, `buzz-minio`, `buzz-minio-init`, `buzz-keycloak`, `buzz-adminer`, `buzz-prometheus` |
| Docker volumes | `buzz-postgres-data`, `buzz-minio-data`, `buzz-prometheus-data` |
| Docker network | `buzz-net` |
| Docker images | `postgres:17-alpine`, `quay.io/keycloak/keycloak:26.0`, `minio/minio`, `minio/mc`, `prom/prometheus`, `adminer:5.5.0` |
| WSL2 `Ubuntu-24.04` | `/home/gifma/projects/buzz` upstream checkout and build |

All relay data, identities, and the DPAPI-protected agent keys were deleted
with the volumes and AppData. No rollback point was kept.

## Kept

- `Ubuntu-24.04` distro: it hosts unrelated tooling.
- `redis:7-alpine` and `adminer:latest` images: used by unrelated containers.
- The pre-existing Windows Cloudflare Tunnel connector: it serves other
  hostnames.
- `/root/buzz-rollbacks/20260806T041832Z-pre-hermes-bridge` on the Hermes VPS:
  outside the approved removal list.

## Owner action

Remove the `buzz.proeduconnect.com` public hostname from the Cloudflare Tunnel
and its DNS record in the Cloudflare dashboard.
