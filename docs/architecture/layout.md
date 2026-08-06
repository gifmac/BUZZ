# Pilot layout and boundaries

The Windows repository is the durable operational layer. It contains only
sanitized documentation, helper scripts, and a loopback-only Compose override.
The upstream Buzz checkout lives at `/home/gifma/projects/buzz` inside the
Ubuntu WSL2 virtual disk for native Linux filesystem performance.

Docker Desktop supplies PostgreSQL, Redis, MinIO, Adminer, Keycloak, and
Prometheus. Their mutable data is stored in Docker named volumes and is not
copied into Git. The Buzz relay is built and run from WSL2 and binds to
`127.0.0.1:13000` during the conflict-free pilot configuration.
The relay's health and metrics listeners use local ports `18088` and `19102`.

Remote Hermes and OpenClaw agents will eventually make outbound WSS connections
to one approved Cloudflare hostname. Only the relay endpoint may be routed by
Cloudflare. Database, cache, object-storage, administration, metrics, Git, and
development endpoints remain local.

Secrets belong in ignored `.env` files or provider-managed credential stores.
Only variable names and sanitized examples belong in this repository.
