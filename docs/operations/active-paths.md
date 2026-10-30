# Active paths and commands

## Local paths

| Purpose | Path |
|---|---|
| Windows pilot repository | `C:\Users\gifma\projects\BUZZ` |
| WSL2 Buzz checkout | `/home/gifma/projects/buzz` |
| Upstream local environment | `/home/gifma/projects/buzz/.env` |
| Local Git object storage | `/home/gifma/projects/buzz/repos` |
| Compose port override | `/mnt/c/Users/gifma/projects/BUZZ/infra/docker/dev-ports.override.yml` |
| Relay runtime logs | `C:\Users\gifma\projects\BUZZ\tmp` |
| Installed desktop | `C:\Users\gifma\AppData\Local\Buzz\buzz-desktop.exe` |
| Latest pre-upgrade rollback bundle | `C:\Users\gifma\AppData\Local\BuzzPilot\backups\20260801-154510-v0.4.26-pre-v0.5.3` |
| Latest pre-public-host rollback bundle | `C:\Users\gifma\AppData\Local\BuzzPilot\backups\20260802-040812-pre-public-canonical-host` |
| Public relay | `wss://buzz.proeduconnect.com` |
| Hermes bridge unit | `buzz-hermes.service` on `srv1069851.hstgr.cloud` |
| Hermes bridge rollback | `/root/buzz-rollbacks/20260806T041832Z-pre-hermes-bridge` |
| OpenClaw VPS | `srv1161177.hstgr.cloud` (`72.61.70.71`), operator SSH only |
| OpenClaw Compose | `/docker/openclaw-kv6w` |
| OpenClaw container | `openclaw-kv6w-openclaw-1` |

Docker live volumes: `buzz-postgres-data`, `buzz-minio-data`, and
`buzz-prometheus-data`.

## Local loopback ports

| Service | Host port |
|---|---:|
| Buzz relay | 13000 |
| Buzz health probe | 18088 |
| Buzz metrics | 19102 |
| PostgreSQL | 15432 |
| Redis | 16379 |
| Adminer | 18082 |
| Keycloak | 18180 |
| MinIO API | 19000 |
| MinIO console | 19001 |
| Prometheus | 19090 |

None of these ports may be added to the Cloudflare ingress configuration except
the Buzz relay endpoint after explicit approval.

## Canonical commands

Run from `C:\Users\gifma\projects\BUZZ`:

```powershell
powershell -File .\scripts\buzz-wsl.ps1 versions
powershell -File .\scripts\buzz-wsl.ps1 setup
powershell -File .\scripts\buzz-wsl.ps1 build
powershell -File .\scripts\start-buzz-relay.ps1
powershell -File .\scripts\start-buzz-desktop.ps1
powershell -File .\scripts\buzz-wsl.ps1 status
powershell -File .\scripts\stop-buzz-relay.ps1
```

Direct WSL shell access for investigation:

```powershell
wsl.exe -d Ubuntu-24.04 --cd /home/gifma/projects/buzz
```

The public Buzz hostname reuses the approved pre-existing Windows Cloudflare
Tunnel. No Cloudflare Access policy exists. The approved Hermes bridge is
active; the OpenClaw bridge remains locally prepared and approval-gated.
SSH access to either VPS is only for bounded operator staging and inspection;
Buzz does not receive or persist an SSH key. The running bridges use outbound
WSS to the existing public relay hostname.
