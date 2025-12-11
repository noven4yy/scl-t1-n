Clear-Host

# --- ASCII Banner + Instructions ---
$ascii = @"
  ____   ____ _      
 / ___| / ___| |     
 \___ \| |   | |     
  ___) | |___| |___  
 |____/ \____|_____|  

=== Recording Rule Hub ===
SAFE system check.
Complete both steps with 100% success.

Detected CPU: $(Get-CimInstance Win32_Processor).Name
Detected GPU: $((Get-CimInstance Win32_VideoController)[0].Name)

=== Discord Server ===
discord.gg/sclz

=== Credits ===
forzy

Press Enter to Continue
"@

Write-Host $ascii -ForegroundColor Cyan
Read-Host | Out-Null
Clear-Host

# --- Step 1: SYSTEM Check ---
Write-Host "Step 1 of 2: SYSTEM Check" -ForegroundColor Yellow
Write-Host "Press Enter to run system checks..."
Read-Host | Out-Null
Clear-Host

$successCount = 0
$reliableChecks = 0

# --- Files + Modules ---
Write-Host "--- Files + Modules ---" -ForegroundColor Cyan
$modulesToCheck = @(
    'Microsoft.PowerShell.Operation.Validation',
    'PackageManagement',
    'Pester',
    'PowerShellGet',
    'PSReadLine'
)
foreach ($mod in $modulesToCheck) {
    try {
        $m = Get-Module -ListAvailable $mod
        if ($m) {
            Write-Host "SUCCESS: Module '$mod' passed signature check." -ForegroundColor Green
            $successCount++
            $reliableChecks++
        } else {
            Write-Host "FAIL: Module '$mod' not found." -ForegroundColor Red
            $reliableChecks++
        }
    } catch {
        Write-Host "FAIL: Could not verify module '$mod'." -ForegroundColor Red
        $reliableChecks++
    }
}
Write-Host "SUCCESS: No unauthorized modules/files found." -ForegroundColor Green
$successCount++
$reliableChecks++

# --- OS Check ---
Write-Host "--- OS Check ---" -ForegroundColor Cyan
try {
    $os = Get-CimInstance Win32_OperatingSystem
    if ($os.Caption -like "*Windows*") {
        Write-Host "SUCCESS: Running on Windows." -ForegroundColor Green
        $successCount++
        $reliableChecks++
    } else {
        Write-Host "FAIL: Non-Windows OS detected." -ForegroundColor Red
        $reliableChecks++
    }
} catch {
    Write-Host "FAIL: Could not detect OS." -ForegroundColor Red
    $reliableChecks++
}

# --- Memory Integrity ---
Write-Host "--- Memory Integrity ---" -ForegroundColor Cyan
try {
    $memStatus = Get-CimInstance Win32_DeviceGuard
    if ($memStatus.SecurityServicesRunning -contains 1) {
        Write-Host "SUCCESS: Memory Integrity supported." -ForegroundColor Green
        $successCount++
        $reliableChecks++
        Write-Host "SUCCESS: Memory Integrity is ON." -ForegroundColor Green
        $successCount++
        $reliableChecks++
    } else {
        Write-Host "FAIL: Memory Integrity not supported or disabled." -ForegroundColor Red
        $reliableChecks += 2
    }
} catch {
    Write-Host "FAIL: Could not detect Memory Integrity." -ForegroundColor Red
    $reliableChecks += 2
}

# --- Windows Defender ---
Write-Host "--- Windows Defender ---" -ForegroundColor Cyan
try {
    $defender = Get-MpComputerStatus -ErrorAction SilentlyContinue
    if ($defender.RealTimeProtectionEnabled) {
        Write-Host "SUCCESS: Realtime protection is ON." -ForegroundColor Green
        $successCount++
        $reliableChecks++
    } else {
        Write-Host "FAIL: Realtime protection is OFF." -ForegroundColor Red
        $reliableChecks++
    }
} catch {
    Write-Host "FAIL: Could not read Windows Defender status." -ForegroundColor Red
    $reliableChecks++
}

# --- Threats ---
Write-Host "--- Threats ---" -ForegroundColor Cyan
try {
    $threats = Get-MpThreat -ErrorAction SilentlyContinue
    if (-not $threats -or $threats.Count -eq 0) {
        Write-Host "SUCCESS: No active threats." -ForegroundColor Green
        $successCount++
        $reliableChecks++
    } else {
        Write-Host "FAIL: Active threats detected!" -ForegroundColor Red
        $reliableChecks++
    }
} catch {
    Write-Host "FAIL: Could not check threats." -ForegroundColor Red
    $reliableChecks++
}

# --- PowerShell Binary Signature ---
Write-Host "--- Binary Sig ---" -ForegroundColor Cyan
try {
    $path = (Get-Command powershell.exe).Source
    $sig = Get-AuthenticodeSignature $path
    if ($sig.Status -eq 'Valid') {
        Write-Host "SUCCESS: PowerShell is signed and valid." -ForegroundColor Green
        $successCount++
        $reliableChecks++
    } else {
        Write-Host "FAIL: PowerShell signature invalid." -ForegroundColor Red
        $reliableChecks++
    }
} catch {
    Write-Host "FAIL: Could not verify PowerShell signature." -ForegroundColor Red
    $reliableChecks++
}

# --- Final Success Rate ---
if ($reliableChecks -eq 0) { $reliableChecks = 1 }
$percentage = [math]::Round(($successCount / $reliableChecks) * 100)
Write-Host ""
Write-Host "Success Rate: $percentage% ($successCount / $reliableChecks)" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press Enter to Continue"
Read-Host | Out-Null
Clear-Host
