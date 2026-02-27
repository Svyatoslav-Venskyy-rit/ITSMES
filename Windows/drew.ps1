Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "Starting cleanup of C2 client (snss.exe)" -ForegroundColor Cyan
Write-Host "Target indicators:" -ForegroundColor Cyan
Write-Host "   • File      : C:\Windows\Fonts\snss.exe" -ForegroundColor Cyan
Write-Host "   • Reg value : 'Font Loader' (common Run/RunOnce locations)" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------------
# 1. Terminate any running snss.exe processes
# ------------------------------------------------------------------
Write-Host "[1/3] Checking for running processes named 'snss'..." -ForegroundColor Yellow

$procs = Get-Process -Name "snss" -ErrorAction SilentlyContinue
if ($procs) {
    foreach ($p in $procs) {
        try {
            Stop-Process -Id $p.Id -Force -ErrorAction Stop
            Write-Host "   ✓ Terminated process ID $($p.Id) (snss.exe)" -ForegroundColor Green
        }
        catch {
            Write-Host "   ✗ Failed to terminate process ID $($p.Id): $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}
else {
    Write-Host "   No running snss.exe processes found." -ForegroundColor Yellow
}

# ------------------------------------------------------------------
# 2. Delete the binary from the exact provided path
# ------------------------------------------------------------------
$binaryPath = "C:\Windows\Fonts\snss.exe"

Write-Host "`n[2/3] Attempting to delete binary..." -ForegroundColor Yellow
Write-Host "   Target: $binaryPath" -ForegroundColor Yellow

if (Test-Path $binaryPath) {
    try {
        Remove-Item -Path $binaryPath -Force -ErrorAction Stop
        Write-Host "   ✓ Successfully deleted $binaryPath" -ForegroundColor Green
    }
    catch {
        Write-Host "   ✗ Failed to delete $binaryPath : $($_.Exception.Message)" -ForegroundColor Red
    }
}
else {
    Write-Host "   Binary not present at the target path." -ForegroundColor Yellow
}

# ------------------------------------------------------------------
# 3. Remove registry value "Font Loader" from all common persistence locations
# ------------------------------------------------------------------
$regKeyName = "Font Loader"

$regLocations = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\RunOnce",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
    "HKCU:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\RunOnce"
)

Write-Host "`n[3/3] Scanning registry for value '$regKeyName'..." -ForegroundColor Yellow

foreach ($loc in $regLocations) {
    if (Test-Path $loc) {
        $exists = Get-ItemProperty -Path $loc -Name $regKeyName -ErrorAction SilentlyContinue
        if ($exists) {
            try {
                Remove-ItemProperty -Path $loc -Name $regKeyName -Force -ErrorAction Stop
                Write-Host "   ✓ Removed '$regKeyName' from $loc" -ForegroundColor Green
            }
            catch {
                Write-Host "   ✗ Failed to remove from $loc : $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        else {
            Write-Host "   Not present in $loc" -ForegroundColor DarkGray
        }
    }
    else {
        Write-Host "   Path does not exist: $loc" -ForegroundColor DarkGray
    }
}

# ------------------------------------------------------------------
# Final summary
# ------------------------------------------------------------------
Write-Host "`n===================================================================" -ForegroundColor Cyan
Write-Host "Cleanup completed." -ForegroundColor Cyan
Write-Host "Only the exact academic indicators (path, filename, and 'Font Loader' registry value) were targeted." -ForegroundColor Cyan
Write-Host "Reboot recommended to ensure no remnants remain in memory." -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan
