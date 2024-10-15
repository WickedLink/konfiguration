# Fixed BitLocker Status Check Script with Computer SID and RunspaceId
# This script checks BitLocker status on remote computers and retrieves recovery keys
# It uses the computer's SID for unique identification and RunspaceId for Windows recovery key matching

# Import required modules
Import-Module BitLocker
Add-Type -AssemblyName System.Windows.Forms

# Define variables for input and output files
$computerListFile = "C:\inst\computerlist_hb.txt"
$outputFile = "C:\inst\bitlocker_results_hb.csv"

# Ensure $cred is defined before running this script
# $cred = Get-Credential

# Function to check BitLocker status and get recovery key
function Get-BitLockerInfo {
    param($ComputerName)
    
    try {
        $result = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
            $computerSID = (Get-WmiObject win32_computersystem).SID
            $bitlockerStatus = Get-BitLockerVolume -MountPoint "C:" -ErrorAction Stop
            if ($bitlockerStatus.VolumeStatus -eq "FullyEncrypted") {
                $recoveryProtector = $bitlockerStatus.KeyProtector | Where-Object { $_.KeyProtectorType -eq "RecoveryPassword" }
                $recoveryKey = $recoveryProtector.RecoveryPassword
                $runspaceId = $recoveryProtector.KeyProtectorId
                return @{
                    ComputerSID = $computerSID
                    RunspaceId = $runspaceId
                    Status = "Online"
                    BitLockerEnabled = "WAHR"
                    RecoveryKey = $recoveryKey
                }
            } else {
                return @{
                    ComputerSID = $computerSID
                    RunspaceId = "N/A"
                    Status = "Online"
                    BitLockerEnabled = "FALSCH"
                    RecoveryKey = "N/A"
                }
            }
        } -ErrorAction Stop

        return [PSCustomObject]@{
            ComputerName = $ComputerName
            ComputerSID = $result.ComputerSID
            RunspaceId = $result.RunspaceId
            Status = $result.Status
            BitLockerEnabled = $result.BitLockerEnabled
            RecoveryKey = $result.RecoveryKey
        }
    } catch {
        return [PSCustomObject]@{
            ComputerName = $ComputerName
            ComputerSID = "N/A"
            RunspaceId = "N/A"
            Status = "Error"
            BitLockerEnabled = "Unknown"
            RecoveryKey = "Error: $($_.Exception.Message)"
        }
    }
}

# Function to display a progress bar
function Show-Progress {
    param (
        [int]$PercentComplete,
        [string]$Status
    )
    Write-Progress -Activity "Checking BitLocker Status" -Status $Status -PercentComplete $PercentComplete
}

# Main script execution
Clear-Host
Write-Host "BitLocker Status Check Script v7.0" -ForegroundColor Cyan

# Check if the CSV file exists
$existingResults = @()
if (Test-Path $outputFile) {
    Write-Host "Existing CSV file found. Reading data..." -ForegroundColor Green
    $existingResults = Import-Csv -Path $outputFile
    Write-Host "Found $(($existingResults | Measure-Object).Count) existing entries." -ForegroundColor Green
    
    # Read all computers from the list file
    $allComputers = Get-Content -Path $computerListFile
    
    # Identify computers that need checking (not in existing results or offline)
    $computersToCheck = $allComputers | Where-Object { 
        $computer = $_
        ($existingResults | Where-Object { $_.ComputerName -eq $computer -and $_.Status -ne "Offline" }) -eq $null
    }
} else {
    Write-Host "No existing CSV file found. Will create a new one." -ForegroundColor Yellow
    # Read all computers from the list file
    $computersToCheck = Get-Content -Path $computerListFile
}

$totalComputers = $computersToCheck.Count
Write-Host "Total computers to process: $totalComputers" -ForegroundColor Green

# Process each computer
Write-Host "`nProcessing computers:" -ForegroundColor Yellow
for ($i = 0; $i -lt $computersToCheck.Count; $i++) {
    $computer = $computersToCheck[$i]
    $percentComplete = [math]::Round(($i + 1) / $totalComputers * 100)
    
    Show-Progress -PercentComplete $percentComplete -Status "Processing $computer ($($i+1)/$totalComputers)"
    
    Write-Host "  Checking $computer... " -NoNewline
    
    # Check if computer is online
    if (Test-Connection -ComputerName $computer -Count 1 -Quiet) {
        Write-Host "Online" -ForegroundColor Green
        
        # Get BitLocker info using the provided credentials
        $bitlockerInfo = Get-BitLockerInfo -ComputerName $computer
        
        # Display BitLocker status
        if ($bitlockerInfo.BitLockerEnabled -eq "WAHR") {
            Write-Host "    BitLocker: Enabled" -ForegroundColor Green
            Write-Host "    Recovery Key: $($bitlockerInfo.RecoveryKey)" -ForegroundColor Yellow
            Write-Host "    RunspaceId: $($bitlockerInfo.RunspaceId)" -ForegroundColor Cyan
        } else {
            Write-Host "    BitLocker: Disabled" -ForegroundColor Red
        }
    } else {
        Write-Host "Offline" -ForegroundColor Red
        $bitlockerInfo = [PSCustomObject]@{
            ComputerName = $computer
            ComputerSID = "N/A"
            RunspaceId = "N/A"
            Status = "Offline"
            BitLockerEnabled = "Unknown"
            RecoveryKey = "N/A"
        }
    }
    
    # Update existing results or add new entry
    $existingEntry = $existingResults | Where-Object { $_.ComputerSID -eq $bitlockerInfo.ComputerSID -or $_.ComputerName -eq $computer }
    if ($existingEntry) {
        $existingEntry.ComputerName = $computer  # Update name in case of rename
        $existingEntry.ComputerSID = $bitlockerInfo.ComputerSID
        $existingEntry.RunspaceId = $bitlockerInfo.RunspaceId
        $existingEntry.Status = $bitlockerInfo.Status
        $existingEntry.BitLockerEnabled = $bitlockerInfo.BitLockerEnabled
        $existingEntry.RecoveryKey = $bitlockerInfo.RecoveryKey
    } else {
        $existingResults += $bitlockerInfo
    }
    
    Write-Host ""
}

# Export updated results to CSV
Write-Host "`nExporting updated results to CSV..." -ForegroundColor Green
$existingResults | Select-Object ComputerName, ComputerSID, RunspaceId, Status, BitLockerEnabled, RecoveryKey | Export-Csv -Path $outputFile -NoTypeInformation

Write-Host "`nResults have been saved to $outputFile" -ForegroundColor Cyan

# Display summary
$onlineCount = ($existingResults | Where-Object { $_.Status -eq "Online" }).Count
$offlineCount = ($existingResults | Where-Object { $_.Status -eq "Offline" }).Count
$enabledCount = ($existingResults | Where-Object { $_.BitLockerEnabled -eq "WAHR" }).Count

Write-Host "`nSummary:" -ForegroundColor Yellow
Write-Host "  Total computers: $(($existingResults | Measure-Object).Count)" -ForegroundColor White
Write-Host "  Online: $onlineCount" -ForegroundColor Green
Write-Host "  Offline: $offlineCount" -ForegroundColor Red
Write-Host "  BitLocker Enabled: $enabledCount" -ForegroundColor Cyan

# Ask if user wants to open the CSV file
$openFile = [System.Windows.Forms.MessageBox]::Show("Do you want to open the CSV file?", "Open Results", [System.Windows.Forms.MessageBoxButtons]::YesNo)
if ($openFile -eq [System.Windows.Forms.DialogResult]::Yes) {
    Invoke-Item $outputFile
}

Write-Host "`nScript execution completed." -ForegroundColor Green
