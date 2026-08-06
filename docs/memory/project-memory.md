# Durable project context

- Pilot owner: local Windows user `gifma`.
- Buzz must remain local during the pilot.
- Use Cloudflare Tunnel/WSS for eventual remote agent connectivity; SSH is not
  a persistent runtime transport.
- Preserve existing Windows and Docker workloads by using dedicated loopback
  ports.
- The upstream source must stay in the WSL2 Linux filesystem.
- Phase one must not create a Cloudflare hostname/tunnel or change either VPS.
- Every human or agent identity receives its own key. The owner key is never an
  agent key.
- Keep documentation sanitized and keep secrets/live state out of Git.
