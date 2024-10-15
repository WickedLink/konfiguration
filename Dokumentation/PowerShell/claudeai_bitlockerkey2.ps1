# Enhanced BitLocker Status Check Script with CSV Update
# This script checks BitLocker status on remote computers and retrieves recovery keys
# It updates an existing CSV file or creates a new one if it doesn't exist

# Import required modules
Import-Module BitLocker
Add-Type -AssemblyName System.Windows.Forms

# Define variables for input and output files
$computerListFile = "C:\inst\computerlist_hb.txt"
$outputFile = "C:\inst\bitlocker_results_hb.csv"

# Ensure $cred is defined before running this script
# $cred = Get-Credential

# Function to show a colorful banner
function Show-Banner {
    Clear-Host
    Write-Host "`n`n" -NoNewline
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "   BitLocker Status Check Script v3.0   " -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "`n"
}

# Function to check BitLocker status and get recovery key
function Get-BitLockerInfo {
    param($ComputerName)
    
    try {
        $bitlockerStatus = Get-BitLockerVolume -MountPoint "C:" -ErrorAction Stop
        if ($bitlockerStatus.VolumeStatus -eq "FullyEncrypted") {
            $recoveryKey = ($bitlockerStatus.KeyProtector | Where-Object { $_.KeyProtectorType -eq "RecoveryPassword" }).RecoveryPassword
            return [PSCustomObject]@{
                ComputerName = $ComputerName
                Status = "Online"
                BitLockerEnabled = $true
                RecoveryKey = $recoveryKey
            }
        } else {
            return [PSCustomObject]@{
                ComputerName = $ComputerName
                Status = "Online"
                BitLockerEnabled = $false
                RecoveryKey = "N/A"
            }
        }
    } catch {
        return [PSCustomObject]@{
            ComputerName = $ComputerName
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
Show-Banner

# Check if the CSV file exists
$existingResults = @()
if (Test-Path $outputFile) {
    Write-Host "Existing CSV file found. Reading data..." -ForegroundColor Green
    $existingResults = Import-Csv -Path $outputFile
    Write-Host "Found $(($existingResults | Measure-Object).Count) existing entries." -ForegroundColor Green
    
    # Filter out computers that are already online
    $computersToCheck = $existingResults | Where-Object { $_.Status -ne "Online" } | Select-Object -ExpandProperty ComputerName
    Write-Host "$(($computersToCheck | Measure-Object).Count) computers need to be rechecked." -ForegroundColor Yellow
} else {
    Write-Host "No existing CSV file found. Will create a new one." -ForegroundColor Yellow
    # Read all computers from the list file
    $computersToCheck = Get-Content -Path $computerListFile
}

$totalComputers = $computersToCheck.Count
Write-Host "Total computers to process: $totalComputers" -ForegroundColor Green

# Initialize results array
$results = @()

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
        $bitlockerInfo = Invoke-Command -ComputerName $computer -Credential $cred -ScriptBlock ${function:Get-BitLockerInfo} -ArgumentList $computer
        
        # Display BitLocker status
        if ($bitlockerInfo.BitLockerEnabled) {
            Write-Host "    BitLocker: " -NoNewline
            Write-Host "Enabled" -ForegroundColor Green
            Write-Host "    Recovery Key: $($bitlockerInfo.RecoveryKey)" -ForegroundColor Yellow
        } else {
            Write-Host "    BitLocker: " -NoNewline
            Write-Host "Disabled" -ForegroundColor Red
        }
    } else {
        Write-Host "Offline" -ForegroundColor Red
        $bitlockerInfo = [PSCustomObject]@{
            ComputerName = $computer
            Status = "Offline"
            BitLockerEnabled = "Unknown"
            RecoveryKey = "N/A"
        }
    }
    
    # Update existing results or add new entry
    $existingEntry = $existingResults | Where-Object { $_.ComputerName -eq $computer }
    if ($existingEntry) {
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
$existingResults | Export-Csv -Path $outputFile -NoTypeInformation

Write-Host "`nResults have been saved to $outputFile" -ForegroundColor Cyan

# Display summary
$onlineCount = ($existingResults | Where-Object { $_.Status -eq "Online" }).Count
$offlineCount = ($existingResults | Where-Object { $_.Status -eq "Offline" }).Count
$enabledCount = ($existingResults | Where-Object { $_.BitLockerEnabled -eq $true }).Count

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
