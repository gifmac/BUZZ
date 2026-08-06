$ErrorActionPreference = 'Stop'

& wsl.exe -d Ubuntu-24.04 --exec bash /mnt/c/Users/gifma/projects/BUZZ/scripts/stop-buzz-relay.sh
if ($LASTEXITCODE -ne 0) {
    throw "Buzz relay stop command failed with exit code $LASTEXITCODE."
}

for ($attempt = 1; $attempt -le 20; $attempt++) {
    $listener = Get-NetTCPConnection -State Listen -LocalPort 13000 -ErrorAction SilentlyContinue
    if (-not $listener) {
        Write-Output 'Buzz relay stopped.'
        exit 0
    }
    Start-Sleep -Seconds 1
}

throw 'Buzz relay did not stop within 20 seconds.'
