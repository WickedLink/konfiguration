# Define variables for input and output files
# $computerListFile = "C:\inst\computerlist_all.txt"
$computerListFile = "C:\inst\computerlist_mi.txt"
$computerListFile = "C:\inst\computerlist_hb.txt"
# $outputFile = "C:\inst\bitlocker_results.csv"
$outputFile = "C:\inst\bitlocker_results_hb.csv"

# Ensure $cred is defined before running this script
# $cred = Get-Credential

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

# Read computer list from file
$computers = Get-Content -Path $computerListFile

# Initialize results array
$results = @()

# Process each computer
foreach ($computer in $computers) {
    Write-Host "Checking $computer..."
    
    # Check if computer is online
    if (Test-Connection -ComputerName $computer -Count 1 -Quiet) {
        # Get BitLocker info using the provided credentials
        $bitlockerInfo = Invoke-Command -ComputerName $computer -Credential $cred -ScriptBlock ${function:Get-BitLockerInfo} -ArgumentList $computer
        $results += $bitlockerInfo
    } else {
        $results += [PSCustomObject]@{
            ComputerName = $computer
            Status = "Offline"
            BitLockerEnabled = "Unknown"
            RecoveryKey = "N/A"
        }
    }
}

# Export results to CSV
$results | Export-Csv -Path $outputFile -NoTypeInformation

Write-Host "Results have been saved to $outputFile"
