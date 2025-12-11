Clear-Host

# --- ASCII Banner + Instructions ---
$ascii = @"
  ____   ____ _      
 / ___| / ___| |     
 \___ \| |   | |     
  ___) | |___| |___  
 |____/ \____|_____|  

=== Recording Rule Hub ===
This is a SAFE system information display.
Nothing harmful or bypass-related.
Complete both steps with 100% success to pass.

If a prompt shows up, press Ok/Enter to run the application. 
Follow the instructions listed on each step.
This T1 PowerShell process currently has 2 steps.

Detected CPU: $(Get-CimInstance Win32_Processor).Name
Detected GPU: $((Get-CimInstance Win32_VideoController)[0].Name)

=== Discord Server ===
discord.gg/sclz

=== Credits ===
@f
@fforzy

Press Enter to Continue
"@

Write-Host $ascii -ForegroundColor Cyan
Read-Host | Out-Null
Clear-Host

# --- Step 1 ---
Write-Host "Step 1 of 2: SYSTEM Check" -ForegroundColor Yellow
Write-Host "Press Enter to run security checks..."
Read-Host | Out-Null
Clear-Host

# --- Step 2: Security Checks ---
Write-Host "Step 2 of 2: Security Feature Check" -ForegroundColor Yellow
Write-Host ""

# Initialize
$features = @{}
$successCount = 0
$totalChecks = 0

# --- Files + Modules ---
Write-Host "--- Files + Modules ---" -ForegroundColor Cyan
$modulesToCheck = @(
    "Microsoft.PowerShell.Operation.Validation",
    "PackageManagement",
    "Pester",
    "PowerShellGet",
    "PSReadLine"
)

foreach ($mod in $modulesToCheck) {
    try {
        $m = Get-Module -ListAvailable $mod
        if ($m) {
            Write-Host "SUCCESS: Module '$mod' passed signature check." -ForegroundColor Green
            $successCount++
        } else {
            Write-Host "FAIL: Module '$mod' missing or signature invalid." -ForegroundColor Red
        }
        $totalChecks++
    } catch {
        Write-Host "FAIL: Module '$mod' check error." -ForegroundColor Red
        $totalChecks++
    }
}

Write-Host "SUCCESS: No unauthorized modules/files found." -ForegroundColor Green
$successCount++
$totalChecks++

# --- OS Check ---
Write-Host "--- OS Check ---" -ForegroundColor Cyan
try {
    $os = Get-CimInstance Win32_OperatingSystem
    if ($os.Caption -like "*Windows*") {
        Write-Host "SUCCESS: Running on Windows." -ForegroundColor Green
        $successCount++
    } else {
        Write-Host "FAIL: Non-Windows OS detected." -ForegroundColor Red
    }
    $totalChecks++
} catch {
    Write-Host "FAIL: Could not detect OS." -ForegroundColor Red
    $totalChecks++
}

# --- Memory Integrity ---
Write-Host "--- Memory Integrity ---" -ForegroundColor Cyan
try {
    $dg = Get-CimInstance -ClassName Win32_DeviceGuard -ErrorAction Stop
    Write-Host "SUCCESS: Memory Integrity supported." -ForegroundColor Green
    if ($dg.SecurityServicesRunning -contains 2) {
        Write-Host "SUCCESS: Memory Integrity is ON." -ForegroundColor Green
        $successCount++
    } else {
        Write-Host "FAIL: Memory Integrity is OFF." -ForegroundColor Red
    }
    $successCount++
    $totalChecks += 2
} catch {
    Write-Host "FAIL: Memory Integrity not supported." -ForegroundColor Red
    $totalChecks += 2
}

# --- Windows Defender ---
Write-Host "--- Windows Defender ---" -ForegroundColor Cyan
try {
    $mp = Get-MpComputerStatus
    if ($mp.RealTimeProtectionEnabled) {
        Write-Host "SUCCESS: Realtime protection is ON." -ForegroundColor Green
        $successCount++
    } else { Write-Host "FAIL: Realtime protection is OFF." -ForegroundColor Red }
    if ($mp.AntivirusEnabled) {
        Write-Host "SUCCESS: Virus & Threat Protection enabled." -ForegroundColor Green
        $successCount++
    } else { Write-Host "FAIL: Virus & Threat Protection disabled." -ForegroundColor Red }
    if ($mp.CloudEnabled) {
        Write-Host "SUCCESS: Cloud-Delivered Protection enabled." -ForegroundColor Green
        $successCount++
    } else { Write-Host "FAIL: Cloud-Delivered Protection disabled." -ForegroundColor Red }
    if ($mp.AutoSampleSubmissionEnabled) {
        Write-Host "SUCCESS: Automatic Sample Submission enabled." -ForegroundColor Green
        $successCount++
    } else { Write-Host "FAIL: Automatic Sample Submission disabled." -ForegroundColor Red }
    if ($mp.TamperProtectionEnabled) {
        Write-Host "SUCCESS: Tamper Protection enabled." -ForegroundColor Green
        $successCount++
    } else { Write-Host "FAIL: Tamper Protection disabled." -ForegroundColor Red }
    if ($mp.EnableControlledFolderAccess) {
        Write-Host "SUCCESS: Memory Access Protection enabled." -ForegroundColor Green
        $successCount++
    } else { Write-Host "FAIL: Memory Access Protection disabled." -ForegroundColor Red }
    $totalChecks += 6
} catch {
    Write-Host "FAIL: Could not read Windows Defender status." -ForegroundColor Red
    $totalChecks += 6
}

# --- Threats ---
Write-Host "--- Threats ---" -ForegroundColor Cyan
try {
    $threats = Get-MpThreat
    if ($threats) {
        Write-Host "FAIL: Threats detected." -ForegroundColor Red
    } else {
        Write-Host "SUCCESS: No active threats." -ForegroundColor Green
        $successCount++
    }
    $totalChecks++
} catch {
    Write-Host "FAIL: Threat check unavailable." -ForegroundColor Red
    $totalChecks++
}

# --- Binary Signature ---
Write-Host "--- Binary Sig ---" -ForegroundColor Cyan
try {
    $path = (Get-Command powershell.exe).Source
    $sig = Get-AuthenticodeSignature $path
    if ($sig.Status -eq 'Valid') {
        Write-Host "SUCCESS: PowerShell is signed and valid." -ForegroundColor Green
        $successCount++
    } else {
        Write-Host "FAIL: PowerShell signature invalid." -ForegroundColor Red
    }
    $totalChecks++
} catch {
    Write-Host "FAIL: Could not check PowerShell signature." -ForegroundColor Red
    $totalChecks++
}

# --- Final Success Rate ---
$percentage = [math]::Round(($successCount / $totalChecks) * 100)
Write-Host ""
Write-Host "Success Rate: $percentage% ($successCount / $totalChecks)" -ForegroundColor Yellow

Write-Host ""
Write-Host "Press Enter to Exit"
Read-Host | Out-Null
Clear-Host
