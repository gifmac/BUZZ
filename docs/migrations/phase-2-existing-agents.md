# Phase two: connect the existing Hermes and OpenClaw agents

Status: Hermes-first rollout is active and has passed the owner-response,
identity, presence, container-isolation, no-listener, and bridge-only restart
checks. The remaining Hermes acceptance check is a mention from an authorized
non-owner test identity, which must be ignored. OpenClaw and Cloudflare remain
unchanged and unauthorized.

## Objective

Connect the already-running Hermes and OpenClaw agents to the existing Buzz
relay at `wss://buzz.proeduconnect.com`.

Phase two does not deploy either agent. It adds one small Buzz ACP bridge
process on each existing VPS. Each bridge:

1. connects outbound to the existing Buzz relay through the current Cloudflare
   Tunnel hostname;
2. starts the ACP interface inside the existing agent container; and
3. uses a unique Buzz-managed identity owned by the Desktop user.

There is no new Cloudflare route, inbound VPS port, agent container, agent
image, duplicate state directory, custom Buzz backend provider, or persistent
SSH transport.

## Existing runtime evidence

Read-only inspection on 2026-08-05 confirmed:

| Agent | Existing runtime | Supported ACP command | Current state |
|---|---|---|---|
| Hermes | `hermes`, image ID `sha256:cee4a522ee3e992b24d675fd36e79808e60afd585843d2e031b3e2ba7917126f` | `hermes acp` | running, zero restarts, ACP check passed |
| OpenClaw | `openclaw-kv6w-openclaw-1`, image ID `sha256:6a31d44b2944e7adcd2b582bf6fb463111264ebca97a0201795b799135bd102c` (`OpenClaw 2026.7.1`) | `openclaw acp` backed by the existing Gateway | healthy, zero restarts; refreshed 2026-08-06 |

Hermes remains owned by:

- Compose project: `hermes-docker`
- Compose files:
  - `/root/hermes-docker/docker-compose.yml`
  - `/root/hermes-docker/docker-compose.override.yml`
- Persistent state: `/root/.hermes -> /opt/data`

OpenClaw remains owned by:

- Compose project: `openclaw-kv6w`
- Compose file: `/docker/openclaw-kv6w/docker-compose.yml`
- Compose SHA-256:
  `641f2cc5b24a172d55af9161321214011d49ed84e18691ec94d375f27ab177d4`
- Existing Gateway: `127.0.0.1:62829` inside the container
- Persistent volumes:
  - `openclaw-kv6w_openclaw_config -> /home/node/.openclaw`
  - `openclaw-kv6w_openclaw_workspace -> /home/node/openclaw`

Neither container currently contains `buzz-acp` or `buzz`. Both VPS hosts
are Ubuntu x86_64 with glibc 2.39 and can reach the public Buzz endpoint with
HTTP 200. No Buzz service or `/opt/buzz`/`/etc/buzz` staging path currently
exists on either host.

The required upstream bridge was built locally from the pinned
`desktop-v0.5.3` checkout:

| Item | Verified value |
|---|---|
| Source commit | `3a96acea09b4a9e3f02c3a26cfb0607d2ccacf42` |
| Local artifact | `/home/gifma/projects/buzz/target/release/buzz-acp` |
| SHA-256 | `a2ab17fb2818a8e3cb5980bc52f221fc2ec22d5263a22f4b80c3479df3dd93a7` |
| Format | x86-64 Linux ELF, dynamically linked |
| Runtime libraries | glibc, libm, libgcc_s; available on both VPS hosts |

### Hermes rollout state (2026-08-06)

- Installed `/opt/buzz/desktop-v0.5.3/bin/buzz-acp`, SHA-256
  `a2ab17fb2818a8e3cb5980bc52f221fc2ec22d5263a22f4b80c3479df3dd93a7`.
- Installed `/opt/buzz/desktop-v0.5.3/bin/hermes-acp-existing`, SHA-256
  `f83a9920e8d3ef83f5b5c883d7e669f87abba6f8e8fb0f0e04183418d5d8fa6a`.
- Installed `/etc/systemd/system/buzz-hermes.service`, SHA-256
  `e48eda39e7b3197fe1f8a51361042ef3d57a4580b42ea5c81be7c88a8bd92a8b`.
- Installed `/etc/buzz/hermes.env` as `root:root` mode `0600`. A sanitized
  verification confirmed exactly the three expected variable names without
  printing their values.
- The unit validates and is enabled/active with zero service restarts. It
  exposes no listener and invokes `hermes acp` inside the existing container.
- Sanitized rollback baseline:
  `/root/buzz-rollbacks/20260806T041832Z-pre-hermes-bridge`.
- Existing Hermes remains container
  `ed3db15963cbd4a8d62f42fa17e72d47091321799f21de9a9c9fadf95b998972`,
  image `sha256:cee4a522ee3e992b24d675fd36e79808e60afd585843d2e031b3e2ba7917126f`,
  running with zero restarts. Its Compose hashes are unchanged.
- The user created the unique `Hermes-VPS` identity through Buzz Desktop,
  saved its one-time key outside the repository using Windows DPAPI, and set
  the Desktop runtime to manual start. The managed-agent store was not edited
  directly.
- Authenticated relay verification found the expected `Hermes-VPS` profile and
  online presence. The owner test response
  `HERMES_BRIDGE_OWNER_OK_20260806` exists exactly once and is signed by the
  expected identity.
- A bounded restart of only `buzz-hermes.service` changed the bridge PID and
  reconnected successfully. The reply remained single-copy, the bridge had
  zero restarts/errors, and the Hermes container ID, image ID, and zero restart
  count remained unchanged.

OpenClaw health reported a pre-existing warning for 61 old dead-lettered
outbound entries. That is baseline evidence, not caused by Buzz, and must not
be repaired as part of this phase.

The 2026-08-06 Gate C refresh confirmed that the OpenClaw container is healthy
with zero restarts, `openclaw acp --help` passes, the host reaches the existing
Buzz hostname with HTTP 200, and the proposed wrapper, secret environment, and
systemd-unit paths are absent. No OpenClaw file or service was changed.

The exact non-secret Gate C files are prepared locally:

| Item | Local path | SHA-256 |
|---|---|---|
| Pinned `buzz-acp` | `/home/gifma/projects/buzz/target/release/buzz-acp` | `a2ab17fb2818a8e3cb5980bc52f221fc2ec22d5263a22f4b80c3479df3dd93a7` |
| Existing-container wrapper | `scripts/remote/openclaw-acp-existing.sh` | `b5e28607b804ffde6b10d827c4d82b9385a303e68d468065dfcff03225edc885` |
| systemd unit | `infra/systemd/buzz-openclaw.service` | `f0977421013cb19e43de688911de62e75a9331cb0387f561d0a617c1400a67fc` |

The wrapper passes `sh -n` and has Unix line endings. The secret environment
file is deliberately not represented in Git.

## Integration architecture

```text
Hermes VPS                              OpenClaw VPS
systemd: buzz-hermes                    systemd: buzz-openclaw
        |                                      |
        | runs pinned buzz-acp                 | runs pinned buzz-acp
        v                                      v
docker compose exec                    docker compose exec
existing hermes container              existing openclaw container
hermes acp                             openclaw acp -> existing Gateway
        |                                      |
        +---------- outbound WSS only ----------+
                           |
                           v
              wss://buzz.proeduconnect.com
```

SSH is used only to stage and inspect the approved files. The persistent
runtime path is outbound WSS from each local systemd bridge to the existing
Cloudflare hostname.

## Exact proposed files

After approval, each VPS receives only:

| Hermes VPS | OpenClaw VPS |
|---|---|
| `/opt/buzz/desktop-v0.5.3/bin/buzz-acp` | `/opt/buzz/desktop-v0.5.3/bin/buzz-acp` |
| `/opt/buzz/desktop-v0.5.3/bin/hermes-acp-existing` | `/opt/buzz/desktop-v0.5.3/bin/openclaw-acp-existing` |
| `/etc/buzz/hermes.env` | `/etc/buzz/openclaw.env` |
| `/etc/systemd/system/buzz-hermes.service` | `/etc/systemd/system/buzz-openclaw.service` |

No existing Compose file, container, image, volume, agent configuration, or
Cloudflare resource is changed.

### Hermes ACP wrapper

The host wrapper calls the ACP interface in the existing service:

```sh
exec docker compose \
  --project-directory /root/hermes-docker \
  -f /root/hermes-docker/docker-compose.yml \
  -f /root/hermes-docker/docker-compose.override.yml \
  exec -T --user hermes --workdir /opt/data \
  hermes /opt/data/.local/bin/hermes acp
```

This uses the existing Hermes installation, model/provider configuration,
credentials, skills, and `/opt/data`. It does not run a second gateway or use
a second state directory.

### OpenClaw ACP wrapper

The host wrapper calls the ACP bridge backed by the existing Gateway:

```sh
exec docker compose \
  --project-directory /docker/openclaw-kv6w \
  -f /docker/openclaw-kv6w/docker-compose.yml \
  exec -T --user node --workdir /home/node/openclaw \
  openclaw openclaw acp --url ws://127.0.0.1:62829
```

The command inherits the existing container Gateway token without placing it on
the command line or copying it into the Buzz environment file.

### Hermes systemd unit

```ini
[Unit]
Description=Buzz bridge for the existing Hermes agent
After=docker.service network-online.target
Requires=docker.service
Wants=network-online.target

[Service]
Type=simple
EnvironmentFile=/etc/buzz/hermes.env
Environment=BUZZ_ACP_AGENT_COMMAND=/opt/buzz/desktop-v0.5.3/bin/hermes-acp-existing
Environment=BUZZ_ACP_AGENT_ARGS=
Environment=BUZZ_ACP_AGENTS=1
Environment=BUZZ_ACP_HEARTBEAT_INTERVAL=0
Environment=BUZZ_ACP_RESPOND_TO=owner-only
Environment=BUZZ_ACP_ALLOWED_RESPOND_TO=owner-only
Environment=BUZZ_ACP_PERMISSION_MODE=dont-ask
ExecStart=/opt/buzz/desktop-v0.5.3/bin/buzz-acp
Restart=on-failure
RestartSec=5
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

### OpenClaw systemd unit

```ini
[Unit]
Description=Buzz bridge for the existing OpenClaw agent
After=docker.service network-online.target
Requires=docker.service
Wants=network-online.target

[Service]
Type=simple
EnvironmentFile=/etc/buzz/openclaw.env
Environment=BUZZ_ACP_AGENT_COMMAND=/opt/buzz/desktop-v0.5.3/bin/openclaw-acp-existing
Environment=BUZZ_ACP_AGENT_ARGS=
Environment=BUZZ_ACP_AGENTS=1
Environment=BUZZ_ACP_HEARTBEAT_INTERVAL=0
Environment=BUZZ_ACP_RESPOND_TO=owner-only
Environment=BUZZ_ACP_ALLOWED_RESPOND_TO=owner-only
Environment=BUZZ_ACP_PERMISSION_MODE=dont-ask
ExecStart=/opt/buzz/desktop-v0.5.3/bin/buzz-acp
Restart=on-failure
RestartSec=5
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

The binary and wrappers are `root:root 0755`, environment files are
`root:root 0600`, and systemd units are `root:root 0644`.

## Desktop harness prerequisites

Complete and verify the Windows Desktop harnesses before creating any remote
VPS identity. Installing the underlying CLI alone is insufficient: Buzz also
requires the corresponding ACP adapter and an authenticated CLI session.

The verified Windows prerequisite state on 2026-08-06 is:

| Harness | Underlying CLI | ACP adapter | Authentication |
|---|---|---|---|
| Codex | `codex-cli 0.144.4` | `@agentclientprotocol/codex-acp@1.1.9` | ChatGPT login active |
| Claude Code | `claude 2.1.222` | `@agentclientprotocol/claude-agent-acp@0.65.0` | Claude.ai Pro login active |

Both adapters are installed in the current Windows user's global npm prefix,
`C:\Users\gifma\AppData\Roaming\npm`. They were installed by exact version,
not by a mutable `latest` reference. The installed adapter version commands
and both underlying CLI authentication probes passed.

The Desktop acceptance steps completed on 2026-08-06:

1. Restart Buzz Desktop once so runtime discovery receives the updated Windows
   PATH and global npm shims.
2. Open **Agents** -> **Set agent defaults** (or **Agent defaults**).
3. Confirm both **Codex** and **Claude Code** are selectable in **Default
   harness** without an install or sign-in warning. Do not reinstall either
   underlying CLI when it is already detected and authenticated.
4. Both harnesses showed Ready; the saved default was not changed as part of
   the remote bridge rollout.

Do not create a disposable agent merely to verify discovery, and do not create
`Hermes-VPS` until all four checks pass. The Desktop harnesses are local
prerequisites only. They do not create a backend provider, install anything on
a VPS, or change the remote Hermes command.

Adapter rollback, if required:

```powershell
npm uninstall -g @agentclientprotocol/codex-acp @agentclientprotocol/claude-agent-acp
```

## Buzz identity and secret contract

Create two managed identities in Buzz Desktop, one rollout at a time:

- `Hermes-VPS`
- `OpenClaw-VPS`

Do not use a backend provider. In the packaged 0.5.3 UI, the main Create Agent
dialog starts a local runtime after creation; it does not expose the backend
`spawnAfterCreate=false` flag. After Desktop reveals the private key once,
immediately stop that local runtime and change the identity to manual start
before using it remotely. Never allow the Desktop runtime and VPS bridge to run
the same identity simultaneously. The owner attestation is stored in:

```text
C:\Users\gifma\AppData\Roaming\xyz.block.buzz.app\agents\managed-agents.json
```

Extract only the selected agent's `auth_tag`; never copy or print the full
managed-agent store.

Each root-owned environment file is mode `0600` and contains only:

```text
BUZZ_RELAY_URL=wss://buzz.proeduconnect.com
BUZZ_PRIVATE_KEY=<that-agent's-unique-nsec>
BUZZ_AUTH_TAG=<that-agent's-owner-attestation>
```

The Hermes key and OpenClaw key must be different. Neither may equal the owner
key or any previous ephemeral smoke-test key. Secrets must not enter Git,
shell history, command arguments, systemd unit text, logs, or operator notes.

## Bridge policy

The two systemd units supply these non-secret settings:

```text
BUZZ_ACP_AGENT_COMMAND=<agent-specific-wrapper>
BUZZ_ACP_AGENT_ARGS=
BUZZ_ACP_AGENTS=1
BUZZ_ACP_HEARTBEAT_INTERVAL=0
BUZZ_ACP_RESPOND_TO=owner-only
BUZZ_ACP_ALLOWED_RESPOND_TO=owner-only
BUZZ_ACP_PERMISSION_MODE=dont-ask
```

The empty `BUZZ_ACP_AGENT_ARGS` is required because each wrapper already
contains the complete ACP command. The locked owner-only policy prevents
runtime widening, and `dont-ask` rejects operations that would require an
unattended interactive approval.

## Implementation order and approval gates

### Gate A: local preparation

Completed:

1. Built only `buzz-acp` from the pinned `desktop-v0.5.3` checkout in release
   mode.
2. Recorded its SHA-256 and verified x86-64/glibc compatibility with both VPS
   hosts.
3. Prepared the exact wrapper and systemd-unit diffs above.
4. Verified the Windows Codex and Claude Code CLIs are installed and
   authenticated.
5. Installed the required ACP adapters at the exact versions recorded in
   **Desktop harness prerequisites** and verified their version commands.

6. Restarted Buzz Desktop and confirmed Buzz Agent, Codex, and Claude Code are
   Ready.
7. Created `Hermes-VPS` in Desktop, saved its one-time key outside the
   repository using DPAPI, stopped its local runtime, and set it to manual
   start. `OpenClaw-VPS` has not been created.

Creating persistent agent identities is a separate user-visible action. Do not
perform it until the user approves the identity names and one-time secret
placement procedure.

### Gate B: Hermes first

Before mutation, present:

- the exact four Hermes files and SHA-256 values;
- ownership and modes;
- the complete systemd unit and wrapper diff;
- the existing Hermes container/image/restart baseline;
- start, verification, and rollback commands.

Approval authorizes only the Hermes bridge. It does not authorize restarting or
recreating Hermes.

Current result: steps 1-7 and 9 of **Verification** passed for Hermes. The
owner-only policy is locked in the unit. Step 8 still requires a separate
authorized non-owner test identity; no identity will be created or reused just
to manufacture that test. OpenClaw remains behind Gate C.

### Gate C: OpenClaw second

Proceed only after Hermes passes. Repeat the exact diff and baseline review for
OpenClaw using its separate identity. Approval authorizes only the OpenClaw
bridge and does not authorize restarting or recreating OpenClaw.

The remaining local prerequisite is creating `OpenClaw-VPS` through Buzz
Desktop, storing its unique one-time key outside the repository, stopping its
Desktop runtime, and setting it to manual start. That identity will first send
the non-owner Hermes test mention; Hermes must produce no response. Only then
may the same identity be staged for the OpenClaw bridge.

## Verification

For each approved bridge:

1. Verify staged binary and wrapper checksums and root-only secret permissions.
2. Run the wrapper with `--help` substituted for the final ACP invocation.
3. Start only the new Buzz systemd unit.
4. Confirm the existing agent container ID, image ID, mounts, health, and
   restart count did not change.
5. Confirm the bridge opens no listening port.
6. Confirm authenticated WSS presence using the expected agent public key
   without printing its nsec or raw auth tag.
7. Send one owner mention and verify exactly one signed response.
8. Send one non-owner mention and verify it is ignored.
9. Restart only the Buzz bridge unit and verify reconnection without duplicate
   responses.
10. Stop only the Buzz bridge and verify the existing Hermes/OpenClaw service
    remains healthy.

Any existing-agent drift, unexpected listener, authentication failure, secret
leak, widened author policy, or result that differs from the approved plan is a
stop condition.

## Rollback

Rollback never touches the existing agent service:

1. `systemctl disable --now buzz-hermes` or
   `systemctl disable --now buzz-openclaw`, as applicable.
2. Move the four additive Buzz files into the pre-created timestamped rollback
   directory.
3. Run `systemctl daemon-reload`.
4. Confirm the existing agent container remains healthy and unchanged.
5. Archive the corresponding Desktop identity; revoke/rotate only that unique
   agent key if compromise is suspected.

## Not authorized

This plan does not authorize:

- a custom `buzz-backend-*` provider;
- a new Hermes or OpenClaw container, image, or state directory;
- a production Compose edit or agent restart;
- any Cloudflare, DNS, hostname, Access, or service-token change;
- any inbound VPS port;
- owner-key export or agent-key reuse; or
- OpenClaw rollout before Hermes acceptance passes.
