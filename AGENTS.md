# BUZZ local pilot operator guide

## Purpose

This repository manages the Windows/WSL2 pilot around the upstream
`block/buzz` checkout. The upstream source stays in the Ubuntu WSL2 filesystem
at `/home/gifma/projects/buzz`; this Windows repository holds sanitized
documentation, loopback-only infrastructure overrides, and operator scripts.

## Hard boundaries

- Buzz remains local during this pilot. Do not deploy it to either VPS.
- Cloudflare Tunnel is the only intended runtime path for remote agents.
- SSH is inspection/configuration only, never the persistent runtime path.
- Do not create a named Cloudflare Tunnel or hostname without user approval.
- Do not modify, restart, or reconfigure Hermes, OpenClaw, or any VPS service
  without first presenting the exact proposed changes and rollback plan.
- Never expose PostgreSQL, Redis, MinIO, Adminer, Keycloak, Prometheus, Git
  storage, or development ports through Cloudflare.
- Use a unique key for every agent. Never reuse the owner key as an agent key.
- Keep secrets and live mutable state outside this Git repository.

## Managed paths

- Windows control repository: `C:\Users\gifma\projects\BUZZ`
- WSL2 upstream checkout: `/home/gifma/projects/buzz`
- WSL2 distro: `Ubuntu-24.04`
- Upstream nonproduction environment: `/home/gifma/projects/buzz/.env`
- Docker named volumes: live state managed by Docker Desktop, not by Git

## Workflow

1. Read `inventory.md` and `docs/operations/active-paths.md`.
2. Inspect status before changes: `powershell -File scripts/buzz-wsl.ps1 status`.
3. State the affected files/services, rollback point, and verification command.
4. Obtain approval before Cloudflare or VPS changes.
5. Apply one approved operational change and verify it immediately.
6. Stop if the observed result differs from the plan.

Do not run destructive reset recipes such as `just reset` unless the user
explicitly requests a data reset and a backup/rollback point exists.

## Verification

Use `scripts/buzz-wsl.ps1` for canonical setup, build, status, and version
commands. Bind pilot ports to loopback. Redact keys, tokens, credentials, and
raw remote configuration from notes and command output.
