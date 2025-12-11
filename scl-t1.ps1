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

# Initialize counters
$successCount = 0
$totalChecks = 0
$reliableChecks = 0

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
    $totalChecks++
} catch {
    Write-Host "FAIL: Could not detect OS." -ForegroundColor Red
    $totalChecks++
}

# --- Antivirus / Windows Defender Checks ---
Write-Host "--- Antivirus & Real-Time Protection ---" -ForegroundColor Cyan
try {
    $mp = Get-CimInstance -Namespace "root/SecurityCenter2" -ClassName "AntiVirusProduct" -ErrorAction SilentlyContinue
    if (-not $mp) {
        # fallback for Windows Defender
        $mp = Get-MpComputerStatus -ErrorAction SilentlyContinue
    }

    $checks = @{}

    if ($mp -is [Microsoft.PowerShell.Commands.Internal.Format.PSObject] -or $mp -is [Array]) {
        # Windows Defender
        $defenderStatus = Get-MpComputerStatus
        $checks = @{
            "Real-Time Protection" = $defenderStatus.RealTimeProtectionEnabled
            "Virus & Threat Protection" = $defenderStatus.AntivirusEnabled
            "Cloud-Delivered Protection" = $defenderStatus.CloudEnabled
            "Automatic Sample Submission" = $defenderStatus.AutoSampleSubmissionEnabled
            "Tamper Protection" = $defenderStatus.TamperProtectionEnabled
            "Controlled Folder Access" = $defenderStatus.EnableControlledFolderAccess
        }
    }

    foreach ($feature in $checks.Keys) {
        $status = $checks[$feature]
        if ($status -eq $true) {
            Write-Host "SUCCESS: $feature is ON." -ForegroundColor Green
            $successCount++
            $reliableChecks++
        } elseif ($status -eq $false) {
            Write-Host "FAIL: $feature is OFF." -ForegroundColor Red
            $reliableChecks++
        } else {
            Write-Host "UNKNOWN: Could not reliably detect $feature." -ForegroundColor Yellow
        }
        $totalChecks++
    }
} catch {
    Write-Host "FAIL: Could not read antivirus status." -ForegroundColor Red
    $totalChecks += 6
}

# --- Active Threats ---
Write-Host "--- Active Threats ---" -ForegroundColor Cyan
try {
    $activeThreats = Get-MpThreat -ErrorAction SilentlyContinue
    if ($activeThreats -and $activeThreats.Count -gt 0) {
        Write-Host "FAIL: Active threats detected!" -ForegroundColor Red
    } else {
        Write-Host "SUCCESS: No active threats detected." -ForegroundColor Green
        $successCount++
        $reliableChecks++
    }
    $totalChecks++
} catch {
    Write-Host "FAIL: Could not check threats." -ForegroundColor Red
    $totalChecks++
}

# --- PowerShell Binary Signature ---
Write-Host "--- PowerShell Binary Signature ---" -ForegroundColor Cyan
try {
    $path = (Get-Command powershell.exe).Source
    $sig = Get-AuthenticodeSignature $path
    if ($sig.Status -eq 'Valid') {
        Write-Host "SUCCESS: PowerShell binary is signed and valid." -ForegroundColor Green
        $successCount++
        $reliableChecks++
    } else {
        Write-Host "FAIL: PowerShell signature invalid." -ForegroundColor Red
        $reliableChecks++
    }
    $totalChecks++
} catch {
    Write-Host "FAIL: Could not verify PowerShell signature." -ForegroundColor Red
    $totalChecks++
}

# --- Final Success Rate ---
if ($reliableChecks -eq 0) { $reliableChecks = 1 } # prevent division by zero
$percentage = [math]::Round(($successCount / $reliableChecks) * 100)
Write-Host ""
Write-Host "Overall Security Success Rate: $percentage% ($successCount / $reliableChecks)" -ForegroundColor Yellow

Write-Host ""
Write-Host "Press Enter to Exit"
Read-Host | Out-Null
Clear-Host
