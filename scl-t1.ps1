Clear-Host

# --- ASCII Banner ---
$ascii = @"
  ____   ____ _      
 / ___| / ___| |     
 \___ \| |   | |     
  ___) | |___| |___  
 |____/ \____|_____|  

=== Recording Rule Hub ===
This is a SAFE system information display.
Nothing harmful or bypass-related.

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
$totalChecks = 7
$successCount = 0

# --- Real-time Protection ---
try {
    $mp = Get-MpComputerStatus
    if ($mp.RealTimeProtectionEnabled) {
        $features["Real-Time Protection"] = "Success"
        $successCount++
    } else { $features["Real-Time Protection"] = "Failed" }
} catch { $features["Real-Time Protection"] = "Failed" }

# --- Virus & Threat Protection ---
try {
    if ($mp.AntivirusEnabled) {
        $features["Virus & Threat Protection"] = "Success"
        $successCount++
    } else { $features["Virus & Threat Protection"] = "Failed" }
} catch { $features["Virus & Threat Protection"] = "Failed" }

# --- Cloud-Delivered Protection ---
try {
    if ($mp.CloudEnabled) {
        $features["Cloud-Delivered Protection"] = "Success"
        $successCount++
    } else { $features["Cloud-Delivered Protection"] = "Failed" }
} catch { $features["Cloud-Delivered Protection"] = "Failed" }

# --- Automatic Sample Submission ---
try {
    if ($mp.AutoSampleSubmissionEnabled) {
        $features["Automatic Sample Submission"] = "Success"
        $successCount++
    } else { $features["Automatic Sample Submission"] = "Failed" }
} catch { $features["Automatic Sample Submission"] = "Failed" }

# --- Tamper Protection ---
try {
    if ($mp.TamperProtectionEnabled) {
        $features["Tamper Protection"] = "Success"
        $successCount++
    } else { $features["Tamper Protection"] = "Failed" }
} catch { $features["Tamper Protection"] = "Failed" }

# --- Device Security: Memory Integrity ---
try {
    $dg = Get-CimInstance -ClassName Win32_DeviceGuard
    if ($dg.SecurityServicesRunning -contains 2) {
        $features["Memory Integrity"] = "Success"
        $successCount++
    } else { $features["Memory Integrity"] = "Failed" }
} catch { $features["Memory Integrity"] = "Failed" }

# --- Memory Access Protection ---
try {
    if ($mp.EnableControlledFolderAccess) {
        $features["Memory Access Protection"] = "Success"
        $successCount++
    } else { $features["Memory Access Protection"] = "Failed" }
} catch { $features["Memory Access Protection"] = "Failed" }

# --- Display Results ---
Write-Host "=== Security Check Results ===" -ForegroundColor Cyan
foreach ($feature in $features.Keys) {
    $status = $features[$feature]
    if ($status -eq "Success") {
        Write-Host "$feature : $status" -ForegroundColor Green
    } else {
        Write-Host "$feature : $status" -ForegroundColor Red
    }
}

# --- Success Percentage ---
$percentage = [math]::Round(($successCount / $totalChecks) * 100)
Write-Host ""
Write-Host "Overall Security Success Rate: $percentage%" -ForegroundColor Yellow
if ($percentage -eq 100) {
    Write-Host "All checks passed ✅" -ForegroundColor Green
} else {
    Write-Host "Some checks failed ❌" -ForegroundColor Red
}

Write-Host ""
Write-Host "Press Enter to Exit"
Read-Host | Out-Null
Clear-Host
