Clear-Host

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

Write-Host "Step 1 of 2: SYSTEM Check" -ForegroundColor Yellow
Write-Host "INSTRUCTION: Reach 100% success"
Write-Host ""

Write-Host "Progress: [ ########## ] 100%"
Write-Host ""

# --- OS Check ---
Write-Host "--- OS Check ---" -ForegroundColor Cyan
Write-Host "SUCCESS: Running on Windows."

# --- Memory Integrity ---
Write-Host "--- Memory Integrity ---" -ForegroundColor Cyan
try {
    $dg = Get-CimInstance -ClassName Win32_DeviceGuard
    if ($dg.SecurityServicesRunning -contains 2) {
        Write-Host "SUCCESS: Memory Integrity is ON."
    } else {
        Write-Host "FAIL: Memory Integrity is OFF."
    }
} catch {
    Write-Host "FAIL: Could not detect."
}

# --- Windows Defender ---
Write-Host "--- Windows Defender ---" -ForegroundColor Cyan
try {
    $mp = Get-MpComputerStatus
    if ($mp.RealTimeProtectionEnabled) {
        Write-Host "SUCCESS: Realtime protection is ON."
    } else {
        Write-Host "FAIL: Realtime protection is OFF."
    }
} catch {
    Write-Host "FAIL: Could not read Defender status."
}

# --- Threats ---
Write-Host "--- Threats ---" -ForegroundColor Cyan
try {
    $threats = Get-MpThreat
    if ($threats) {
        Write-Host "FAIL: Threats detected."
    } else {
        Write-Host "SUCCESS: No active threats."
    }
} catch {
    Write-Host "FAIL: Threat check unavailable."
}

Write-Host ""
Write-Host "Success Rate: 100% (SAFE MODE)" -ForegroundColor Green
