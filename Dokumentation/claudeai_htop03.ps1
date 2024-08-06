function Show-ProcessMonitor {
    param (
        [int]$Count = 20,
        [string]$SortBy = "CPU",
        [string]$Filter = "*"
    )

    $sortBy = $SortBy.ToLower()
    $sortDescending = $true
    $hostname = $env:COMPUTERNAME

    while ($true) {
        Clear-Host
#        Write-Host "Process Monitor" -ForegroundColor Cyan
        Write-Host "Process Monitor - Running on $hostname" -ForegroundColor Cyan
        Write-Host "Press: Q to quit, K to kill, C (CPU), M (Memory), N (Name), V (Version) to sort, D to change display count, F to filter" -ForegroundColor Yellow
        Write-Host "Currently sorting by: $sortBy ($(if ($sortDescending) {'Descending'} else {'Ascending'}))" -ForegroundColor Green
        Write-Host "Displaying top $Count processes" -ForegroundColor Green
        Write-Host "Current filter: $Filter" -ForegroundColor Green
        Write-Host

        $processes = Get-Process | Where-Object { $_.Name -like $Filter } | Select-Object Name, ID, 
            @{Name="CPU (s)"; Expression={if ($_.CPU -ne $null) {$_.CPU.ToString("N2")} else {"0.00"}}},
            @{Name="Memory (MB)"; Expression={($_.WorkingSet / 1MB).ToString("N2")}},
            @{Name="Version"; Expression={
                try {
                    $_.MainModule.FileVersionInfo.FileVersion
                } catch {
                    "N/A"
                }
            }}

        switch ($sortBy) {
            "name" { $processes = $processes | Sort-Object Name -Descending:$sortDescending }
            "cpu" { $processes = $processes | Sort-Object {[double]($_."CPU (s)" -replace '[^\d.]')} -Descending:$sortDescending }
            "memory" { $processes = $processes | Sort-Object {[double]($_."Memory (MB)" -replace '[^\d.]')} -Descending:$sortDescending }
            "version" { $processes = $processes | Sort-Object Version -Descending:$sortDescending }
        }

        $processes | Select-Object -First $Count | Format-Table -AutoSize

        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        switch ($key.Character) {
            'q' { return }
            'k' {
                $processId = Read-Host "Enter the Process ID to kill"
                try {
                    Stop-Process -Id $processId -Force
                    Write-Host "Process with ID $processId has been terminated." -ForegroundColor Green
                }
                catch {
                    Write-Host "Failed to terminate process. Error: $_" -ForegroundColor Red
                }
                Read-Host "Press Enter to continue"
            }
            'c' { 
                if ($sortBy -eq "cpu") { $sortDescending = !$sortDescending }
                else { $sortBy = "cpu"; $sortDescending = $true }
            }
            'm' { 
                if ($sortBy -eq "memory") { $sortDescending = !$sortDescending }
                else { $sortBy = "memory"; $sortDescending = $true }
            }
            'n' { 
                if ($sortBy -eq "name") { $sortDescending = !$sortDescending }
                else { $sortBy = "name"; $sortDescending = $false }
            }
            'v' { 
                if ($sortBy -eq "version") { $sortDescending = !$sortDescending }
                else { $sortBy = "version"; $sortDescending = $true }
            }
            'd' {
                $newCount = Read-Host "Enter the number of processes to display"
                if ($newCount -match '^\d+$') {
                    $Count = [int]$newCount
                }
                else {
                    Write-Host "Invalid input. Please enter a number." -ForegroundColor Red
                    Read-Host "Press Enter to continue"
                }
            }
            'f' {
                $newFilter = Read-Host "Enter the filter (e.g., 'n*' for processes starting with 'n', '*pad*' for processes containing 'pad', '*' for all)"
                if ($newFilter) {
                    $Filter = if ($newFilter -like "*`**") { $newFilter } else { "*$newFilter*" }
                }
                else {
                    Write-Host "Invalid input. Filter not changed." -ForegroundColor Red
                    Read-Host "Press Enter to continue"
                }
            }
        }
    }
}

# Usage example
Show-ProcessMonitor -Count 20 -SortBy "CPU" -Filter "*"
