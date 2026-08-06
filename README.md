# BUZZ

This is the control repository for a local-only Buzz pilot on Windows 11,
Docker Desktop, and WSL2. The pinned upstream Buzz source is stored in the
Linux filesystem rather than under `/mnt/c`.

## Source of truth

- Pilot rules and runbooks: this repository
- Upstream application source: `/home/gifma/projects/buzz` in `Ubuntu-24.04`
- Live databases/object data: Docker Desktop named volumes
- Local nonproduction application settings: the ignored upstream `.env`
- Cloudflare connector and future agent credentials: external secret stores
  only; never committed here

The relay and all dependency ports remain loopback-only. The public relay at
`wss://buzz.proeduconnect.com` reuses an approved pre-existing Windows
Cloudflare Tunnel. Both VPS integrations remain behind a separate user approval
gate.

## Common commands

```powershell
powershell -File .\scripts\buzz-wsl.ps1 versions
powershell -File .\scripts\buzz-wsl.ps1 setup
powershell -File .\scripts\buzz-wsl.ps1 build
powershell -File .\scripts\start-buzz-relay.ps1
powershell -File .\scripts\start-buzz-desktop.ps1
powershell -File .\scripts\buzz-wsl.ps1 status
powershell -File .\scripts\stop-buzz-relay.ps1
```

See [inventory.md](inventory.md) for readiness and conflicts, and
[`docs/operations/active-paths.md`](docs/operations/active-paths.md) for exact
paths and ports.
