$ErrorActionPreference = 'Stop'

$existing = Get-NetTCPConnection -State Listen -LocalPort 13000 -ErrorAction SilentlyContinue
if ($existing) {
    Write-Output 'Buzz relay is already listening on 127.0.0.1:13000.'
    exit 0
}

$logDirectory = Join-Path $PSScriptRoot '..\tmp'
New-Item -ItemType Directory -Force -Path $logDirectory | Out-Null
$stdoutPath = Join-Path $logDirectory 'buzz-relay.stdout.log'
$stderrPath = Join-Path $logDirectory 'buzz-relay.stderr.log'

$process = Start-Process -FilePath 'wsl.exe' `
    -ArgumentList @('-d', 'Ubuntu-24.04', '--exec', 'bash', '/mnt/c/Users/gifma/projects/BUZZ/scripts/run-buzz-relay.sh') `
    -WindowStyle Hidden `
    -RedirectStandardOutput $stdoutPath `
    -RedirectStandardError $stderrPath `
    -PassThru

for ($attempt = 1; $attempt -le 60; $attempt++) {
    if ($process.HasExited) {
        $details = Get-Content -LiteralPath $stderrPath -Tail 40 -ErrorAction SilentlyContinue
        throw "Buzz relay exited before readiness. $details"
    }
    try {
        $response = Invoke-WebRequest -Uri 'http://127.0.0.1:13000/_readiness' -UseBasicParsing -TimeoutSec 2
        if ($response.StatusCode -eq 200) {
            Write-Output "Buzz relay ready on ws://127.0.0.1:13000 (Windows wrapper PID $($process.Id))."
            exit 0
        }
    } catch {
        Start-Sleep -Seconds 1
    }
}

throw 'Buzz relay did not become ready within 60 seconds.'
