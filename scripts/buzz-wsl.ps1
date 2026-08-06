param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('bootstrap', 'setup', 'build', 'status', 'versions')]
    [string]$Action
)

$ErrorActionPreference = 'Stop'

$distro = 'Ubuntu-24.04'
$repoPath = '/home/gifma/projects/buzz'
$overridePath = '/mnt/c/Users/gifma/projects/BUZZ/infra/docker/dev-ports.override.yml'
$composeFiles = "$repoPath/docker-compose.yml`:$overridePath"

$recipe = switch ($Action) {
    'bootstrap' { 'just bootstrap' }
    'setup' { 'just setup' }
    'build' { 'just build' }
    'status' { 'docker compose ps' }
    'versions' {
        'git rev-parse HEAD; git describe --tags --exact-match 2>/dev/null || true; cargo --version; rustc --version; node --version; pnpm --version; just --version; hermit version; docker --version; docker compose version'
    }
}

$linuxCommand = "set -euo pipefail; cd '$repoPath'; . ./bin/activate-hermit; export COMPOSE_FILE='$composeFiles'; $recipe"

& wsl.exe -d $distro --exec bash -lc $linuxCommand
exit $LASTEXITCODE
