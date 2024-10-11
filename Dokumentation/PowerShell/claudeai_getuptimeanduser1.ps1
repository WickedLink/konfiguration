# Define credentials
# $cred = Get-Credential -Message "Enter credentials with necessary permissions"

# Read computer names from a text file
# $computers = Get-Content -Path "C:\inst\computerlist_all.txt"
# $computers = Get-Content -Path "C:\inst\computerlist_mi.txt"
$computers = Get-Content -Path "C:\inst\computerlist_p.txt"
# $computers = Get-Content -Path "C:\inst\computerlist_hb.txt"

# Function to get uptime
function Get-Uptime {
    param($lastBootTime)
    $uptime = (Get-Date) - $lastBootTime
    return "{0} days, {1} hours, {2} minutes" -f $uptime.Days, $uptime.Hours, $uptime.Minutes
}

# Array to store results
$results = @()

foreach ($computer in $computers) {
    Write-Host "Checking $computer..." -ForegroundColor Cyan
    
    if (Test-Connection -ComputerName $computer -Count 1 -Quiet) {
        Write-Host "  - Online" -ForegroundColor Green
        
        try {
            $session = New-CimSession -ComputerName $computer -Credential $cred -ErrorAction Stop

            # Get OS info
            try {
                $os = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $session
                $uptime = Get-Uptime -lastBootTime $os.LastBootUpTime
            } catch {
                Write-Host "  - Error retrieving OS info: $($_.Exception.Message)" -ForegroundColor Red
                $uptime = "N/A"
            }

            # Get user info
            try {
                $user = Invoke-Command -ComputerName $computer -Credential $cred -ScriptBlock {
                    $explorerProcesses = Get-WmiObject Win32_Process -Filter "Name = 'explorer.exe'"
                    if ($explorerProcesses) {
                        $explorerProcesses | ForEach-Object { $_.GetOwner().User } | Select-Object -First 1
                    } else {
                        "No user logged on"
                    }
                }
            } catch {
                Write-Host "  - Error retrieving user info: $($_.Exception.Message)" -ForegroundColor Red
                $user = "N/A"
            }

            $results += [PSCustomObject]@{
                Computer = $computer
                Status = "Online"
                User = $user
                Uptime = $uptime
            }
            
            Write-Host "  - Logged on user: $user" -ForegroundColor Yellow
            Write-Host "  - Uptime: $uptime" -ForegroundColor Yellow

            Remove-CimSession -CimSession $session
        }
        catch {
            Write-Host "  - Error creating session: $($_.Exception.Message)" -ForegroundColor Red
            $results += [PSCustomObject]@{
                Computer = $computer
                Status = "Error"
                User = "N/A"
                Uptime = "N/A"
            }
        }
    }
    else {
        Write-Host "  - Offline" -ForegroundColor Red
        $results += [PSCustomObject]@{
            Computer = $computer
            Status = "Offline"
            User = "N/A"
            Uptime = "N/A"
        }
    }
    
    Write-Host ""
}

# Display results in a formatted table
$results | Format-Table -AutoSize

# Export results to CSV
$results | Export-Csv -Path "C:\inst\uptime_results.csv" -NoTypeInformation

Write-Host "Results have been exported to results.csv" -ForegroundColor Green
