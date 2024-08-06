# Set execution policy and install PSWindowsUpdate module
Set-ExecutionPolicy Bypass -Scope Process -Force
if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
}

# Import required modules
Import-Module ActiveDirectory
Import-Module PSWindowsUpdate

# Get admin credentials
$cred = Get-Credential -Message "Enter admin credentials for remote operations"

# Function to check if a computer is online
function Test-ComputerOnline($computerName) {
    Test-Connection -ComputerName $computerName -Count 1 -Quiet
}

# Function to get available updates
function Get-AvailableUpdates($computerName) {
    Invoke-Command -ComputerName $computerName -Credential $cred -ScriptBlock {
        # Set execution policy to bypass for this session
        Set-ExecutionPolicy Bypass -Scope Process -Force

        # Ensure PSWindowsUpdate is installed on the remote machine
        if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
            Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
        }
        
        # Import the module
        Import-Module PSWindowsUpdate -Force

        # Get Windows updates
        Get-WindowsUpdate -MicrosoftUpdate
    }
}

# Function to create and run a scheduled task for installing updates
function Install-UpdatesAsSystem($computerName) {
    $taskName = "InstallWindowsUpdates_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    $action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-NoProfile -WindowStyle Hidden -Command `"Set-ExecutionPolicy Bypass -Scope Process -Force; Import-Module PSWindowsUpdate; Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot | Out-File C:\Windows\Temp\WindowsUpdateLog.txt; Unregister-ScheduledTask -TaskName '$taskName' -Confirm:`$false`""
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1)
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    $task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal

    Invoke-Command -ComputerName $computerName -Credential $cred -ScriptBlock {
        # Remove old update tasks if they exist
        Get-ScheduledTask | Where-Object {$_.TaskName -like "InstallWindowsUpdates_*"} | Unregister-ScheduledTask -Confirm:$false

        # Register and start the new task
        Register-ScheduledTask -TaskName $using:taskName -InputObject $using:task -Force
        Start-ScheduledTask -TaskName $using:taskName
    }
    
    Write-Host "Scheduled task '${taskName}' created and started on ${computerName}."
    Write-Host "The task will self-delete after completion."
}



# Main script
$computers = Get-Content -Path "C:\inst\ComputerList_updates.txt"

foreach ($computer in $computers) {
    Write-Host "Checking computer: ${computer}"
    if (Test-ComputerOnline $computer) {
        Write-Host "${computer} is online."
        $updates = Get-AvailableUpdates $computer
        
        if ($updates.Count -gt 0) {
            Write-Host "Available updates for ${computer}:"
            $updates | Format-Table -AutoSize
            
            $install = Read-Host "Do you want to install updates on ${computer}? (Y/N)"
            if ($install -eq "Y") {
                Write-Host "Installing updates on ${computer}..."
                Install-UpdatesAsSystem $computer
                Write-Host "Scheduled task created to install updates on ${computer}."
            }
        } else {
            Write-Host "No updates available for ${computer}."
        }
    } else {
        Write-Host "${computer} is offline."
    }
    Write-Host ""
}
