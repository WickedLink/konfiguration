# Define the path for input and output files
$computerListPath = "C:\inst\ComputerList.txt"
$outputPath = "C:\Path\To\BitLockerStatus.txt"

# Function to check if a computer is online
function Test-ComputerOnline($computerName) {
    return Test-Connection -ComputerName $computerName -Count 1 -Quiet
}

# Function to check BitLocker status and get recovery key
function Get-BitLockerInfo($computerName) {
    try {
        $bitlockerVolume = Get-BitLockerVolume -MountPoint "C:" -ComputerName $computerName -ErrorAction Stop
        $isEncrypted = $bitlockerVolume.VolumeStatus -eq "FullyEncrypted"
        $recoveryKey = ($bitlockerVolume.KeyProtector | Where-Object {$_.KeyProtectorType -eq "RecoveryPassword"}).RecoveryPassword
        return @{
            IsEncrypted = $isEncrypted
            RecoveryKey = $recoveryKey
        }
    }
    catch {
        return @{
            IsEncrypted = $false
            RecoveryKey = "N/A"
        }
    }
}

# Main script
$computers = Get-Content $computerListPath

foreach ($computer in $computers) {
    if (Test-ComputerOnline $computer) {
        $bitlockerInfo = Get-BitLockerInfo $computer
        $username = (Get-WmiObject -ComputerName $computer -Class Win32_ComputerSystem).UserName
        
        $result = "{0},{1},{2},{3}" -f $username, $computer, $bitlockerInfo.IsEncrypted, $bitlockerInfo.RecoveryKey
        Add-Content -Path $outputPath -Value $result
    }
    else {
        $result = "N/A,{0},Offline,N/A" -f $computer
        Add-Content -Path $outputPath -Value $result
    }
}

Write-Host "Script completed. Results written to $outputPath"
