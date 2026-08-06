# Sanitized setup history

## 2026-07-31 — phase one

- Confirmed the Windows target folder was empty and no Git worktree would be
  overwritten.
- Inventoried Windows, WSL2, Docker Desktop, capacity, toolchains, occupied
  ports, and existing containers.
- Installed a dedicated Ubuntu 24.04 WSL2 distro and created the non-root
  `gifma` user.
- Cloned upstream Buzz into the WSL Linux filesystem and pinned `v0.4.26` at
  commit `0096d710ed2e6abab19aaf7cdc14e3ee603d7ec8`.
- Added required Ubuntu build packages and activated the Hermit-pinned
  toolchain.
- Added a loopback-only Compose override to avoid ports already used by Twenty,
  Windows PostgreSQL, CrawlerX Redis, and Apache httpd.
- Ran `just setup` and `just build` successfully.
- Corrected the pilot-only Keycloak development database and health probe after
  the upstream service started unhealthy.
- Started and validated the local relay on port 13000.
- Performed a signed CLI create/get/delete smoke test with an ephemeral key.
- Downloaded the official Buzz Desktop 0.4.26 Windows installer, verified its
  published SHA-256, and installed it per-user.
- Did not create Cloudflare resources, inspect/modify either VPS, or persist
  agent/owner keys.

## 2026-08-01 — dependency image pinning

- Replaced the mutable Adminer, MinIO, MinIO client, and Prometheus `latest`
  references with exact release tags in the Windows Compose override.
- Verified each release tag resolves to the same manifest digest as the
  existing container image.
- Validated the merged Compose configuration without recreating or restarting
  any container.

## 2026-08-01 — local upgrade to desktop-v0.5.3

- Stopped the local relay and Desktop, then created an external rollback bundle
  containing the ignored environment, local repositories, Desktop state and
  installation, a logical PostgreSQL dump, and the three named-volume archives.
- Validated every ZIP/TAR archive and confirmed the PostgreSQL dump contains a
  readable table-of-contents before changing the checkout.
- Fetched and detached the upstream checkout at `desktop-v0.5.3`, commit
  `3a96acea09b4a9e3f02c3a26cfb0607d2ccacf42`.
- Added only the new upstream S3 development settings missing from the ignored
  `.env`; no values were copied into this repository or operator output.
- Repaired the canonical WSL `versions` wrapper so it reports the exact commit,
  tag, Hermit toolchain, Docker, and Compose versions without nested-shell
  quoting failures.
- Ran canonical `setup` and `build` successfully. Database migrations 25
  (`relay invites`) and 26 (`replica heartbeat`) are recorded as successful.
- Recreated only Adminer, MinIO, Prometheus, and the MinIO initializer so the
  running containers adopted exact release image names; persistent data
  services and named volumes were preserved.
- Downloaded the official Windows x64 v0.5.3 installer and verified its
  published SHA-256 before the in-place per-user upgrade. The asset remains
  explicitly alpha/unsigned.
- Started the locally built relay, confirmed liveness/readiness HTTP 200, and
  passed a signed create/get/delete smoke test with a unique ephemeral key.
- Launched Desktop 0.5.3 against `ws://127.0.0.1:13000` and confirmed the
  process remained stable while all dependencies stayed loopback-only and
  healthy.
- Did not create or modify Cloudflare resources, either VPS, Hermes, OpenClaw,
  persistent agent keys, or production services.

## 2026-08-02 — canonical public relay hostname

- Reused the approved pre-existing auto-start Windows Cloudflare Tunnel; no new
  tunnel, connector, Cloudflare Access application, Service Auth policy, or
  service token was created.
- Added `buzz.proeduconnect.com` to the existing tunnel with the origin
  `http://localhost:13000`. Higher-priority path rules return HTTP 404 for
  readiness, liveness, and metrics endpoints.
- Created and validated a fresh external rollback bundle containing the ignored
  environment, Desktop launcher, and a PostgreSQL custom-format dump before
  changing canonical host configuration.
- Set the relay canonical URL and Desktop launcher to
  `wss://buzz.proeduconnect.com`; the relay bind remained
  `127.0.0.1:13000`.
- Restarted only Buzz Desktop and the local relay. The relay created exactly one
  community row for the public hostname; dependency containers and cloudflared
  were not restarted.
- Confirmed public NIP-11 HTTP 200, WSS receipt of a NIP-42 challenge, signed
  create/get/delete with an ephemeral key, and null post-delete lookup.
- Confirmed Desktop 0.5.3 remained running and local relay readiness stayed
  HTTP 200.
- Did not inspect or modify Hermes, OpenClaw, either VPS, or persistent agent
  keys.
