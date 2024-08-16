# Set execution policy and install PSWindowsUpdate module
Set-ExecutionPolicy Bypass -Scope Process -Force
if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Write-Host "Installing PSWindowsUpdate module locally..." -ForegroundColor Cyan
    Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
}

# Import required modules
Import-Module ActiveDirectory
Import-Module PSWindowsUpdate

# Get admin credentials
# $cred = Get-Credential -Message "Enter admin credentials for remote operations"

# Function to check if a computer is online
function Test-ComputerOnline($computerName) {
    Write-Host "  Checking connectivity for $computerName..." -ForegroundColor Gray -NoNewline
    $result = Test-Connection -ComputerName $computerName -Count 1 -Quiet
    if ($result) {
        Write-Host " Online" -ForegroundColor Green
    } else {
        Write-Host " Offline" -ForegroundColor Red
    }
    return $result
}

# Function to get available updates
function Get-AvailableUpdates($computerName) {
    Write-Host "  Checking for updates on $computerName..." -ForegroundColor Yellow
    Invoke-Command -ComputerName $computerName -Credential $cred -ScriptBlock {
        # Set execution policy to bypass for this session
        Set-ExecutionPolicy Bypass -Scope Process -Force

        # Ensure PSWindowsUpdate is installed on the remote machine
        if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
            Write-Host "    Installing PSWindowsUpdate module on $env:COMPUTERNAME..." -ForegroundColor Cyan
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
            Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
        }
        
        # Import the module
        Import-Module PSWindowsUpdate -Force

        # Get Windows updates
        # Get-WindowsUpdate -MicrosoftUpdate
        # Get-WindowsUpdate -Category "update" -MicrosoftUpdate
        # Get-WindowsUpdate -Category "update" -WindowsUpdate
        Get-WindowsUpdate -NotCategory drivers
    }
}

# Function to create and run a scheduled task for installing updates
function Install-UpdatesAsSystem($computerName) {
    $taskName = "InstallWindowsUpdates_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    # $action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-NoProfile -WindowStyle Hidden -Command `"Set-ExecutionPolicy Bypass -Scope Process -Force; Import-Module PSWindowsUpdate; Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot | Out-File C:\Windows\Temp\WindowsUpdateLog.txt; Unregister-ScheduledTask -TaskName '$taskName' -Confirm:`$false`""
    $action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-NoProfile -WindowStyle Hidden -Command `"Set-ExecutionPolicy Bypass -Scope Process -Force; Import-Module PSWindowsUpdate; Install-WindowsUpdate -NotCategory drivers -AcceptAll -IgnoreReboot | Out-File C:\Windows\Temp\WindowsUpdateLog.txt; Unregister-ScheduledTask -TaskName '$taskName' -Confirm:`$false`""
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1)
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    $task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal

    Write-Host "  Creating and starting update task on $computerName..." -ForegroundColor Yellow
    Invoke-Command -ComputerName $computerName -Credential $cred -ScriptBlock {
        # Remove old update tasks if they exist
        Get-ScheduledTask | Where-Object {$_.TaskName -like "InstallWindowsUpdates_*"} | ForEach-Object {
            Write-Host "    Removing old task: $($_.TaskName)" -ForegroundColor Gray
            Unregister-ScheduledTask -TaskName $_.TaskName -Confirm:$false
        }

        # Register and start the new task
        Register-ScheduledTask -TaskName $using:taskName -InputObject $using:task -Force
        Start-ScheduledTask -TaskName $using:taskName
    }
    
    Write-Host "  Scheduled task '$taskName' created and started on $computerName." -ForegroundColor Green
    Write-Host "  The task will self-delete after completion." -ForegroundColor Gray
    Write-Host "  Check C:\Windows\Temp\WindowsUpdateLog.txt on $computerName for results." -ForegroundColor Cyan
}

# Main script

# Main script
Clear-Host
Write-Host "Windows Update Remote Management Script" -ForegroundColor Magenta
Write-Host "=======================================" -ForegroundColor Magenta

$mode = Read-Host "Choose operation mode:`n1. Check for updates`n2. Check and install updates`nEnter your choice (1 or 2)"

$computers = Get-Content -Path "C:\inst\ComputerList_updates.txt"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outputFile = "C:\inst\UpdateReport_$timestamp.txt"

foreach ($computer in $computers) {
    Write-Host "`nProcessing computer: ${computer}" -ForegroundColor Blue
    if (Test-ComputerOnline $computer) {
        try {
            $updates = Get-AvailableUpdates $computer
            
            if ($updates.Count -gt 0) {
                Write-Host "  Available updates for ${computer}:" -ForegroundColor Green
                $updates | Format-Table -AutoSize | Out-Host
                
                "Updates for ${computer}:" | Out-File -Append -FilePath $outputFile
                $updates | Format-Table -AutoSize | Out-File -Append -FilePath $outputFile
                "`n" | Out-File -Append -FilePath $outputFile
                
                if ($mode -eq "2") {
                    $install = Read-Host "  Do you want to install updates on ${computer}? (Y/N)"
                    if ($install -eq "Y") {
                        Install-UpdatesAsSystem $computer
                    } else {
                        Write-Host "  Skipping update installation for ${computer}." -ForegroundColor Yellow
                    }
                }
            } else {
                Write-Host "  No updates available for ${computer}." -ForegroundColor Green
                "No updates available for $computer`n" | Out-File -Append -FilePath $outputFile
            }
        } catch {
            Write-Host "  Error processing ${computer}: $_" -ForegroundColor Red
            "Error processing ${computer}: $_`n" | Out-File -Append -FilePath $outputFile
        }
    }
    Write-Host "`n  ----------------------------------------" -ForegroundColor Gray
}

Write-Host "Update report saved to $outputFile" -ForegroundColor Cyan
Write-Host "`nScript execution completed." -ForegroundColor Magenta
