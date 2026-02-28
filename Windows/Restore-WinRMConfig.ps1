# Run as Administrator
$backupDir = "C:\WinRMBackup"
$regFile = "$backupDir\wsman.reg"

# Check if backup file exists
if (-not (Test-Path $regFile)) {
    Write-Error "Backup file not found: $regFile"
    exit 1
}

# Stop WinRM service
try {
    Stop-Service -Name WinRM -Force -ErrorAction Stop
    Write-Host "WinRM service stopped"
} catch {
    Write-Error "Failed to stop WinRM service: $_"
    exit 1
}

# Import the registry key
try {
    & reg import $regFile
    if (-not $?) {
        throw "Registry import failed with exit code $LASTEXITCODE"
    }
    Write-Host "WinRM configuration restored from $regFile"
} catch {
    Write-Error "Error during restore: $_"
    # Attempt to restart service even if import failed
    Start-Service -Name WinRM
    exit 1
}

# Start WinRM service
try {
    Start-Service -Name WinRM -ErrorAction Stop
    Write-Host "WinRM service started"
} catch {
    Write-Error "Failed to start WinRM service: $_"
    exit 1
}
