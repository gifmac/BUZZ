# Buzz pilot inventory

Inventory date: 2026-08-06 (America/New_York)

## Recommendation

**GO for the local developer and remote-connectivity pilot.** The pinned Buzz
source builds, all local dependency checks pass, the relay remains bound to
loopback, the approved public WSS hostname passed an authenticated CLI
write/read/delete round-trip, and the packaged Windows desktop client is
running through that hostname.

**GO for the approved Hermes-VPS bridge pilot.** Its outbound-only Buzz ACP
bridge is active, owner-only, and verified without changing or restarting the
existing Hermes container. **NO-GO for the production Compose bundle or the
OpenClaw integration.** Upstream issue
[`block/buzz#2814`](https://github.com/block/buzz/issues/2814) had not been
cleared by this pilot, and the production stack has not been fresh-volume
validated at the selected tag. The public relay reuses an approved pre-existing
Windows Cloudflare Tunnel; OpenClaw changes remain behind a separate explicit
approval gate.

## Host inventory

| Item | Detected value |
|---|---|
| Windows | Windows 11 Home, 10.0.26200, build 26200 |
| CPU | Intel Core i9-13900HX, 32 logical processors |
| Physical memory | 31.75 GiB; 3.27 GiB free at initial inventory |
| C: storage | 1,860.79 GiB total; 687.26 GiB free |
| WSL | 2.6.1.0, kernel 6.6.87.2, WSL2 |
| User distro | Ubuntu 24.04.4 LTS (`Ubuntu-24.04`) |
| Docker Desktop | 4.72.0 (225998) |
| Docker Engine | 29.4.2, Linux/amd64, 32 CPUs, 15.49 GiB memory limit |
| Docker Compose | v5.1.3 |

The host already had 16 running containers at initial inventory. No unrelated
container was stopped, removed, or reconfigured during setup or upgrade; only
the Buzz-owned dependency containers explicitly recorded below were changed.

## Source and toolchain matrix

| Component | Selected/detected version |
|---|---|
| Upstream source | `block/buzz` |
| Release tag | `desktop-v0.5.3` |
| Commit | `3a96acea09b4a9e3f02c3a26cfb0607d2ccacf42` |
| WSL source path | `/home/gifma/projects/buzz` |
| WSL Git | 2.43.0 |
| Hermit | v0.52.3 stable |
| Hermit Rust/Cargo | rustc 1.95.0; cargo 1.95.0 |
| Hermit Node | 24.15.0 |
| Hermit pnpm | 11.4.0 |
| Hermit just | 1.46.0 |
| Windows Git | 2.49.0.windows.1 |
| Windows Rust/Cargo | 1.93.0 |
| Windows Node | 24.13.0 |
| Windows pnpm | 10.28.2 |
| Windows Codex | 0.144.4 |
| Windows Codex ACP adapter | `@agentclientprotocol/codex-acp@1.1.9` |
| Windows Claude Code | 2.1.222 |
| Windows Claude ACP adapter | `@agentclientprotocol/claude-agent-acp@0.65.0` |
| Windows cloudflared | 2026.1.2 |

The upstream checkout is detached at the exact release tag and remains clean.

## Detected conflicts and mitigations

| Original port | Existing owner | Pilot mitigation |
|---:|---|---|
| 3000 | Docker-published Twenty test server | Buzz relay moved to `127.0.0.1:13000` |
| 5432 | Windows PostgreSQL 18 | Buzz PostgreSQL moved to `127.0.0.1:15432` |
| 6379 | CrawlerX Redis/Docker forwarding | Buzz Redis moved to `127.0.0.1:16379` |
| 8080 | Windows `httpd` | Buzz health moved to local port 18088 |

Requested ports 9000, 9001, 8082, and 8108 were free at initial inventory.
The pilot nevertheless remaps every Buzz dependency to a dedicated loopback
port so a later service start cannot silently collide.

The upstream Keycloak service used in-memory H2 and probed health on application
port 8080. It started unhealthy and returned HTTP 500 after initialization. The
pilot override uses the supported `dev-file` database, enables health/metrics,
and probes the internal management port 9000. The recreated Buzz-only Keycloak
container is healthy and its application endpoint redirects normally (HTTP
302).

## Container image digests

These are the exact images pulled by the successful setup:

| Pinned image reference | Content digest |
|---|---|
| `postgres:17-alpine` | `sha256:742f40ea20b9ff2ff31db5458d127452988a2164df9e17441e191f3b72252193` |
| `redis:7-alpine` | `sha256:ee64a64eaab618d88051c3ade8f6352d11531fcf79d9a4818b9b183d8c1d18ba` |
| `adminer:5.5.0` | `sha256:73c3e6b38ec134164b44a37217a9dab783528edc136acf67a3e780944f761ce6` |
| `quay.io/keycloak/keycloak:26.0` | `sha256:09a381c715ab0b111835b70f2905955274843a219c6f27efb348e4d9f4086858` |
| `minio/minio:RELEASE.2025-09-07T16-13-09Z` | `sha256:14cea493d9a34af32f524e538b8346cf79f3321eff8e708c1e2960462bd8936e` |
| `minio/mc:RELEASE.2025-08-13T08-35-41Z` | `sha256:a7fe349ef4bd8521fb8497f55c6042871b2ae640607cf99d9bede5e9bdf11727` |
| `prom/prometheus:v3.13.2` | `sha256:508729e0e2d18e11fd742a5a5ca70e557b940a93948c3c95fd0123a6fd538b69` |

The mutable `latest` references initially used for Adminer, MinIO, the MinIO
client, and Prometheus were replaced in the Windows Compose override on
2026-08-01. Each release tag resolved to the previously recorded manifest
digest. Adminer, MinIO, Prometheus, and the one-shot MinIO initializer were then
recreated so their running configuration records the exact release names;
named-volume data was preserved.

## Upstream issue #2814 assessment

The selected `desktop-v0.5.3` Dockerfile now creates `/data/git` and applies
`buzz:buzz` ownership before switching to `USER buzz:buzz`. This is relevant to
the named-volume ownership failure, but upstream issue #2814 was still open on
2026-08-01 and this pilot did not perform a destructive fresh-volume production
deployment test. The production bundle therefore remains **NO-GO** pending a
separately reviewed validation or upstream closure.

The root developer Compose stack does not use that production Git volume. The
developer setup and local Git path `/home/gifma/projects/buzz/repos` work, so
the issue does not block this local phase.

## Build and validation evidence

| Check | Result |
|---|---|
| `just setup` | PASS; migrations, seed data, pnpm dependencies, hooks |
| `just build` | PASS; full Rust workspace, dev profile |
| Compose config | PASS; all published dependency ports bind `127.0.0.1` |
| PostgreSQL | PASS; `pg_isready` accepting connections |
| Redis | PASS; `PONG` |
| MinIO | PASS; live health endpoint |
| Keycloak | PASS after pilot override; container healthy |
| Prometheus | PASS; healthy endpoint |
| Relay | PASS; liveness 200 `ok`, readiness 200 `ready` |
| NIP-11 | PASS locally and at `https://buzz.proeduconnect.com`; `Buzz Relay`, relay version 0.2.0 |
| Public WSS | PASS; TLS/WebSocket connection received the NIP-42 authentication challenge |
| Buzz CLI | PASS through the public hostname; signed create/get/delete and null post-delete read |
| Upstream worktree | PASS; clean detached release checkout |
| Windows desktop | PASS; Buzz 0.5.3 installed per-user and launched against `wss://buzz.proeduconnect.com` |
| Hermes-VPS bridge | PASS owner response, expected signature, online presence, no listener, bridge-only restart, and unchanged Hermes container/image/restart count; non-owner-ignore test pending |

The official Windows asset
`Buzz_0.5.3_x64-setup_alpha-unsigned.exe` matched its published SHA-256
`43295e951f851a91b5012ae87c30a3c375f07f762ab382763247fa11697a89f3`.
The asset and installed binary are explicitly unsigned; this is recorded as a
pilot risk, not treated as a production-ready distribution signal.

## Approval-gated work and boundaries

- No new named tunnel was created; the approved Buzz hostname reuses the
  pre-existing auto-start Windows connector.
- Cloudflare routes only the Buzz relay origin. Public readiness, liveness, and
  metrics paths return HTTP 404.
- No Cloudflare Access application, Service Auth policy, or service token was
  created.
- The approved Hermes host received only the pinned `buzz-acp` artifact, its
  existing-container wrapper, a root-owned systemd unit, and a root-only mode
  `0600` environment file. The existing Hermes Compose files, image, container,
  state, and restart count remain unchanged.
- OpenClaw was inspected read-only during planning but was not modified. Its
  rollout remains unauthorized.
- The unique Hermes-VPS agent key is stored outside Git using Windows DPAPI and
  in the root-only VPS bridge environment. The owner key was never exported or
  reused.
- The Buzz relay was not deployed to either VPS or to production; the Hermes
  host runs only the outbound bridge to the existing Windows relay hostname.
