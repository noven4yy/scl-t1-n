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
forzy

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

# --- Antivirus / Windows Defender Checks ---
Write-Host "--- Antivirus & Real-Time Protection ---" -ForegroundColor Cyan
try {
    # Get current live AV status
    $mp = Get-MpComputerStatus

    # Real-Time Protection
    if ($mp.RealTimeProtectionEnabled) {
        Write-Host "SUCCESS: Real-Time Protection is ON." -ForegroundColor Green
        $successCount++
    } else { Write-Host "FAIL: Real-Time Protection is OFF." -ForegroundColor Red }
    $totalChecks++

    # Virus & Threat Protection
    if ($mp.AntivirusEnabled) {
        Write-Host "SUCCESS: Virus & Threat Protection is ON." -ForegroundColor Green
        $successCount++
    } else { Write-Host "FAIL: Virus & Threat Protection is OFF." -ForegroundColor Red }
    $totalChecks++

    # Cloud-Delivered Protection
    if ($mp.CloudEnabled) {
        Write-Host "SUCCESS: Cloud-Delivered Protection is ON." -ForegroundColor Green
        $successCount++
    } else { Write-Host "FAIL: Cloud-Delivered Protection is OFF." -ForegroundColor Red }
    $totalChecks++

    # Automatic Sample Submission
    if ($mp.AutoSampleSubmissionEnabled) {
        Write-Host "SUCCESS: Automatic Sample Submission is ON." -ForegroundColor Green
        $successCount++
    } else { Write-Host "FAIL: Automatic Sample Submission is OFF." -ForegroundColor Red }
    $totalChecks++

    # Tamper Protection
    if ($mp.TamperProtectionEnabled) {
        Write-Host "SUCCESS: Tamper Protection is ON." -ForegroundColor Green
        $successCount++
    } else { Write-Host "FAIL: Tamper Protection is OFF." -ForegroundColor Red }
    $totalChecks++

    # Memory Access Protection (Controlled Folder Access)
    if ($mp.EnableControlledFolderAccess) {
        Write-Host "SUCCESS: Memory Access Protection is ON." -ForegroundColor Green
        $successCount++
    } else { Write-Host "FAIL: Memory Access Protection is OFF." -ForegroundColor Red }
    $totalChecks++
} catch {
    Write-Host "FAIL: Could not read live antivirus status." -ForegroundColor Red
    $totalChecks += 6
}

# --- Active Threats Only ---
Write-Host "--- Active Threats ---" -ForegroundColor Cyan
try {
    $activeThreats = Get-MpThreat | Where-Object {$_.Resources -and $_.Resources -ne ""}
    if ($activeThreats.Count -eq 0) {
        Write-Host "SUCCESS: No active threats detected." -ForegroundColor Green
        $successCount++
    } else {
        Write-Host "FAIL: Active threats detected!" -ForegroundColor Red
    }
    $totalChecks++
} catch {
    Write-Host "FAIL: Could not check threats." -ForegroundColor Red
    $totalChecks++
}

# --- Binary Signature ---
Write-Host "--- PowerShell Binary Signature ---" -ForegroundColor Cyan
try {
    $path = (Get-Command powershell.exe).Source
    $sig = Get-AuthenticodeSignature $path
    if ($sig.Status -eq 'Valid') {
        Write-Host "SUCCESS: PowerShell binary is signed and valid." -ForegroundColor Green
        $successCount++
    } else {
        Write-Host "FAIL: PowerShell signature invalid." -ForegroundColor Red
    }
    $totalChecks++
} catch {
    Write-Host "FAIL: Could not verify PowerShell signature." -ForegroundColor Red
    $totalChecks++
}

# --- Final Success Rate ---
$percentage = [math]::Round(($successCount / $totalChecks) * 100)
Write-Host ""
Write-Host "Overall Security Success Rate: $percentage% ($successCount / $totalChecks)" -ForegroundColor Yellow

Write-Host ""
Write-Host "Press Enter to Exit"
Read-Host | Out-Null
Clear-Host
