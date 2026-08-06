$ErrorActionPreference = 'Stop'

$relay = Get-NetTCPConnection -State Listen -LocalPort 13000 -ErrorAction SilentlyContinue
if (-not $relay) {
    throw 'Buzz relay is not listening. Run scripts\start-buzz-relay.ps1 first.'
}

$desktopPath = Join-Path $env:LOCALAPPDATA 'Buzz\buzz-desktop.exe'
if (-not (Test-Path -LiteralPath $desktopPath)) {
    throw "Buzz Desktop is not installed at $desktopPath."
}

$env:BUZZ_RELAY_URL = 'wss://buzz.proeduconnect.com'
$gitBash = 'C:\Program Files\Git\bin\bash.exe'
if (Test-Path -LiteralPath $gitBash) {
    $env:BUZZ_SHELL = $gitBash
}

Start-Process -FilePath $desktopPath
