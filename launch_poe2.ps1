# Path
$exePath = "E:\Path of Exile 2\PathOfExile.exe"

# Process name
$processNameInTaskManager = "PathOfExile"

# TTW
$sleepTime = 4

# Core count
$coreCount = [Environment]::ProcessorCount

# Enabled core
$enabledCores = 2..($coreCount - 1)

# Exec
Write-Host "Launching process..."
Start-Process $exePath -PassThru
Start-Sleep -Seconds $sleepTime

# Timeout
$timeout = 10
$elapsedTime = 0
$ActivePID = $null

# Look for active PID
while ($ActivePID -eq $null -and $elapsedTime -lt $timeout) {
    $processList = Get-Process -Name $processNameInTaskManager -ErrorAction SilentlyContinue
    if ($processList) {
        $ActivePID = $processList.Id
    } else {
        Start-Sleep -Seconds 1
        $elapsedTime++
    }
}

# SET AFFINITY
if ($ActivePID -ne $null) {
    Write-Host "Process launched successfully. Configuring affinity..."

    # Calculate the bitmask for the enabled cores
    $bitmask = 0
    foreach ($core in $enabledCores) {
        $bitmask = $bitmask -bor (1 -shl $core)
    }

    # Apply the calculated affinity to the process
    $processHandle = [System.Diagnostics.Process]::GetProcessById($ActivePID)
    $processHandle.ProcessorAffinity = $bitmask

    # Display enabled and disabled cores
    $disabledCores = 0..($coreCount - 1) | Where-Object { $_ -notin $enabledCores }
    Write-Host "Processor affinity set:"
    Write-Host " - Enabled cores: $($enabledCores -join ', ')"
    Write-Host " - Disabled cores: $($disabledCores -join ', ')"

    # Exit
    Exit
} else {
    # If failed
    Write-Host "Process did not start within the timeout period of $timeout seconds."
}

# Exit
Write-Host "Exiting script..."
