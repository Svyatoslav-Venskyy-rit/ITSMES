# Run as Administrator
$backupDir = "C:\WinRMBackup"
$regFile = "$backupDir\wsman.reg"

# Create backup directory if it doesn't exist
if (-not (Test-Path $backupDir)) {
    try {
        New-Item -Path $backupDir -ItemType Directory -ErrorAction Stop | Out-Null
        Write-Host "Backup directory created: $backupDir"
    } catch {
        Write-Error "Failed to create backup directory: $_"
        exit 1
    }
}

# Export the WinRM registry key
try {
    & reg export "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN" $regFile /y
    if (-not $?) {
        throw "Registry export failed with exit code $LASTEXITCODE"
    }
    Write-Host "WinRM configuration backed up successfully to $regFile"
} catch {
    Write-Error "Error during backup: $_"
    exit 1
}
