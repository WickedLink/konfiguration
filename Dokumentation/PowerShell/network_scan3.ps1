$ipRange = "192.168.1.1-192.168.1.254"

$ipRangeArray = $ipRange -split '-'
$start = [ipaddress]$ipRangeArray[0]
$end = [ipaddress]$ipRangeArray[1]

$startInt = [int]($start.GetAddressBytes()[0]) * 16777216 + [int]($start.GetAddressBytes()[1]) * 65536 + [int]($start.GetAddressBytes()[2]) * 256 + [int]($start.GetAddressBytes()[3])
$endInt = [int]($end.GetAddressBytes()[0]) * 16777216 + [int]($end.GetAddressBytes()[1]) * 65536 + [int]($end.GetAddressBytes()[2]) * 256 + [int]($end.GetAddressBytes()[3])

for ($i = $startInt; $i -le $endInt; $i++) {
    $byte1 = ($i -band 0xFF000000) -shr 24
    $byte2 = ($i -band 0x00FF0000) -shr 16
    $byte3 = ($i -band 0x0000FF00) -shr 8
    $byte4 = $i -band 0x000000FF
    $ipAddress = "$byte1.$byte2.$byte3.$byte4"
    Write-Host "Pinging $ipAddress..."

    if (Test-Connection -ComputerName $ipAddress -Count 1 -Quiet) {
        Write-Host "  $ipAddress is reachable"
        try {
            $computerName = (Resolve-DnsName -Name $ipAddress -Type PTR).NameHost
            Write-Host "  Computer name: $computerName"
        } catch {
            Write-Host "  Unable to retrieve computer name"
        }
    }
}


$ipRange = "192.168.15.1-192.168.15.254"
$computerNames = @()

$ipRangeArray = $ipRange -split '-'
$start = [ipaddress]$ipRangeArray[0]
$end = [ipaddress]$ipRangeArray[1]

$startInt = [int]($start.GetAddressBytes()[0]) * 16777216 + [int]($start.GetAddressBytes()[1]) * 65536 + [int]($start.GetAddressBytes()[2]) * 256 + [int]($start.GetAddressBytes()[3])
$endInt = [int]($end.GetAddressBytes()[0]) * 16777216 + [int]($end.GetAddressBytes()[1]) * 65536 + [int]($end.GetAddressBytes()[2]) * 256 + [int]($end.GetAddressBytes()[3])

for ($i = $startInt; $i -le $endInt; $i++) {
    $byte1 = ($i -band 0xFF000000) -shr 24
    $byte2 = ($i -band 0x00FF0000) -shr 16
    $byte3 = ($i -band 0x0000FF00) -shr 8
    $byte4 = $i -band 0x000000FF
    $ipAddress = "$byte1.$byte2.$byte3.$byte4"
    Write-Host "Pinging $ipAddress..."

    if (Test-Connection -ComputerName $ipAddress -Count 1 -Quiet) {
        Write-Host "  $ipAddress is reachable"
        try {
            $computerName = (Resolve-DnsName -Name $ipAddress -Type PTR).NameHost
            Write-Host "  Computer name: $computerName"
            $computerNames += $computerName
        } catch {
            Write-Host "  Unable to retrieve computer name"
        }
    }
}

Write-Host "Retrieved computer names:"
$computerNames | ForEach-Object { Write-Host "  $_" }

##########################################

$ipRange = "192.168.1.1-192.168.1.254"
$computerNames = @()

$startTime = Get-Date
Write-Host "Scan started at $startTime"

$ipRangeArray = $ipRange -split '-'
$start = [ipaddress]$ipRangeArray[0]
$end = [ipaddress]$ipRangeArray[1]

$startInt = [int]($start.GetAddressBytes()[0]) * 16777216 + [int]($start.GetAddressBytes()[1]) * 65536 + [int]($start.GetAddressBytes()[2]) * 256 + [int]($start.GetAddressBytes()[3])
$endInt = [int]($end.GetAddressBytes()[0]) * 16777216 + [int]($end.GetAddressBytes()[1]) * 65536 + [int]($end.GetAddressBytes()[2]) * 256 + [int]($end.GetAddressBytes()[3])

for ($i = $startInt; $i -le $endInt; $i++) {
    $byte1 = ($i -band 0xFF000000) -shr 24
    $byte2 = ($i -band 0x00FF0000) -shr 16
    $byte3 = ($i -band 0x0000FF00) -shr 8
    $byte4 = $i -band 0x000000FF
    $ipAddress = "$byte1.$byte2.$byte3.$byte4"
    Write-Host "Pinging $ipAddress..."

    if (Test-Connection -ComputerName $ipAddress -Count 1 -Quiet) {
        Write-Host "  $ipAddress is reachable"
        try {
            $fqdn = (Resolve-DnsName -Name $ipAddress -Type PTR).NameHost
            $hostname = $fqdn.Split('.')[0]
            Write-Host "  Computer name: $hostname"
            $computerNames += $hostname
        } catch {
            Write-Host "  Unable to retrieve computer name"
        }
    }
}

$endTime = Get-Date
Write-Host "Scan completed at $endTime"

$executionTime = $endTime - $startTime
Write-Host "Scan took $($executionTime.TotalSeconds) seconds to complete"

Write-Host "Retrieved computer names:"
$computerNames | ForEach-Object { Write-Host "  $_" }


##############


$currentUser = $env:USERNAME
$isAdmin = Get-LocalGroupMember -Group "Administrators" -Member $currentUser -ErrorAction SilentlyContinue
if ($isAdmin) {
    Write-Host "The current user $currentUser is an administrator on this computer."
} else {
    Write-Host "The current user $currentUser is not an administrator on this computer."
}

#############

$username = "stadthagen\fel841"
$isAdmin = Get-LocalGroupMember -Group "Administrators" -Member $username -ErrorAction SilentlyContinue
if ($isAdmin) {
    Write-Host "The user $username is an administrator on this computer."
} else {
    Write-Host "The user $username is not an administrator on this computer."
}

$username = "STADTHAGEN\fel841"
$admins = Get-LocalGroupMember -Group "Administrators" -ErrorAction SilentlyContinue
if ($admins.Name -contains $username) {
    Write-Host "The user $username is an administrator on this computer."
} else {
    Write-Host "The user $username is not an administrator on this computer."
}


if ($admins.Name | Where-Object { $_ -eq $username }) {
    Write-Host "The user $username is an administrator on this computer."
} else {
    Write-Host "The user $username is not an administrator on this computer."
}

##################

function Show-Menu {
    Clear-Host
    Write-Host "Menu" -ForegroundColor Green
    Write-Host "-----" -ForegroundColor Green
    Write-Host "1. Option 1"
    Write-Host "2. Option 2"
    Write-Host "3. Option 3"
    Write-Host "Q. Quit"

    $choice = Read-Host "Enter your choice"

    switch ($choice) {
        "1" { Do-Option1 }
        "2" { Do-Option2 }
        "3" { Do-Option3 }
        "Q" { Exit }
        default { Write-Host "Invalid choice. Try again." -ForegroundColor Red }
    }
}

function Do-Option1 {
    Write-Host "You chose option 1!"
    Read-Host "Press Enter to continue"
}

function Do-Option2 {
    Write-Host "You chose option 2!"
    Read-Host "Press Enter to continue"
}

function Do-Option3 {
    Write-Host "You chose option 3!"
    Read-Host "Press Enter to continue"
}

Show-Menu

#############

# Get system metrics
$cpuUsage = (Get-Counter -Counter "Prozessor(_Total)\Prozessorzeit (%)").CounterSamples.CookedValue
$memUsage = (Get-Counter -Counter "Arbeitsspeicher\Verwendeter Arbeitsspeicher (%)").CounterSamples.CookedValue
$diskUsage = (Get-Counter -Counter "Logischer Datenträger(C:)\Freier Speicherplatz (%)").CounterSamples.CookedValue
$networkInbound = (Get-Counter -Counter "Netzwerkschnittstelle(*)\Empfangene Bytes/Sek.").CounterSamples.CookedValue
$networkOutbound = (Get-Counter -Counter "Netzwerkschnittstelle(*)\Gesendete Bytes/Sek.").CounterSamples.CookedValue

# Get process list
$processes = Get-Process | Select-Object @{Name="Name";Expression={$_.Name}}, @{Name="CPU";Expression={$_.CPU / 100}}, @{Name="Mem";Expression={$_.WorkingSet / 1MB}}, @{Name="Threads";Expression={$_.Threads.Count}}

# Display system metrics
Write-Host "  System Überwachungstool"
Write-Host "  ----------------------"
Write-Host "  CPU-Auslastung:  $($cpuUsage.ToString("F2"))% ($($env:NUMBER_OF_PROCESSORS) Kerne)"
Write-Host "  Arbeitsspeicher-Auslastung:  $($memUsage.ToString("F2"))% ($($env:MEMORY_TOTAL) GB)"
Write-Host "  Festplatten-Auslastung:  $($diskUsage.ToString("F2"))% (C:)"
Write-Host "  Netzwerk-Aktivität:"
Write-Host "    Eingehend:  $($networkInbound.ToString("F2")) KB/s"
Write-Host "    Ausgehend:  $($networkOutbound.ToString("F2")) KB/s"

# Display process list
Write-Host "  Prozesse:"
Write-Host "  +---------------+-------+-------+-------+"
Write-Host "  |  Prozessname  |  CPU  |  Mem  |  Threads  |"
Write-Host "  +---------------+-------+-------+-------+"
$processes | ForEach-Object {
    $name = $_.Name
    $cpu = $_.CPU
    $mem = $_.Mem
    $threads = $_.Threads
    Write-Host ("  | {0,-15} | {1,6:F2}% | {2,6:F2} MB | {3,6}  |" -f $name, $cpu, $mem, $threads)
}
Write-Host "  +---------------+-------+-------+-------+"

# Handle user input
while ($true) {
    $key = Read-Host "Drücken Sie 'q', um zu beenden, 'r', um zu aktualisieren, 'p', um Updates zu pausieren/fortzusetzen"
    switch ($key) {
        "q" { Exit }
        "r" { 
            # Refresh data
        }
        "p" { 
            # Pause/resume updates
        }
        default { Write-Host "Ungültige Eingabe. Versuchen Sie es erneut." -ForegroundColor Red }
    }
}

##################

Get-Counter -List *
Get-Counter -ListSet *
Get-Counter -ListSet Prozessor
Get-Counter -ListSet "Processor Information"
Get-Counter -ListSet Pro*

################

function Show-Menu {
    Clear-Host
    Write-Host "Main Menu" -ForegroundColor Green
    Write-Host "---------" -ForegroundColor Green
    Write-Host "1. System Monitoring"
    Write-Host "2. Process Management"
    Write-Host "3. Network Configuration"
    Write-Host "4. Exit"
    Write-Host "---------" -ForegroundColor Green
    $choice = Read-Host "Enter your choice"
    switch ($choice) {
        1 { Show-SystemMonitoring }
        2 { Show-ProcessManagement }
        3 { Show-NetworkConfiguration }
        4 { Exit }
        default { Write-Host "Invalid choice. Try again." -ForegroundColor Red; Show-Menu }
    }
}

function Show-SystemMonitoring {
    Clear-Host
    Write-Host "System Monitoring" -ForegroundColor Green
    Write-Host "----------------" -ForegroundColor Green
    Write-Host "1. CPU Usage"
    Write-Host "2. Memory Usage"
    Write-Host "3. Disk Usage"
    Write-Host "4. Back to Main Menu"
    Write-Host "----------------" -ForegroundColor Green
    $choice = Read-Host "Enter your choice"
    switch ($choice) {
        1 { Get-CpuUsage }
        2 { Get-MemoryUsage }
        3 { Get-DiskUsage }
        4 { Show-Menu }
        default { Write-Host "Invalid choice. Try again." -ForegroundColor Red; Show-SystemMonitoring }
    }
}

function Get-CpuUsage {
    # code to get CPU usage
    Write-Host "CPU Usage: 50%" -ForegroundColor Yellow
    Read-Host "Press Enter to continue"
    Show-SystemMonitoring
}

function Get-MemoryUsage {
    # code to get memory usage
    Write-Host "Memory Usage: 75%" -ForegroundColor Yellow
    Read-Host "Press Enter to continue"
    Show-SystemMonitoring
}

function Get-DiskUsage {
    # code to get disk usage
    Write-Host "Disk Usage: 90%" -ForegroundColor Yellow
    Read-Host "Press Enter to continue"
    Show-SystemMonitoring
}

Show-Menu

########################

function Show-Menu {
    $menuItems = @(
        "System Monitoring"
        "Process Management"
        "Network Configuration"
        "Exit"
    )
    $selectedIndex = 0

    while ($true) {
        Clear-Host
        Write-Host "Main Menu" -ForegroundColor Green
        Write-Host "---------" -ForegroundColor Green

        for ($i = 0; $i -lt $menuItems.Count; $i++) {
            if ($i -eq $selectedIndex) {
                Write-Host "->$($menuItems[$i])" -ForegroundColor Yellow
            } else {
                Write-Host " $($menuItems[$i])"
            }
        }

        Write-Host "---------" -ForegroundColor Green
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

        switch ($key.VirtualKeyCode) {
            38 { $selectedIndex = ($selectedIndex - 1) % $menuItems.Count } # Up arrow
            40 { $selectedIndex = ($selectedIndex + 1) % $menuItems.Count } # Down arrow
            13 { # Enter key
                switch ($selectedIndex) {
                    0 { Show-SystemMonitoring }
                    1 { Show-ProcessManagement }
                    2 { Show-NetworkConfiguration }
                    3 { Exit }
                }
            }
        }
    }
}

function Show-SystemMonitoring {
    $menuItems = @(
        "CPU Usage"
        "Memory Usage"
        "Disk Usage"
        "Back to Main Menu"
    )
    $selectedIndex = 0

    while ($true) {
        Clear-Host
        Write-Host "System Monitoring" -ForegroundColor Green
        Write-Host "----------------" -ForegroundColor Green

        for ($i = 0; $i -lt $menuItems.Count; $i++) {
            if ($i -eq $selectedIndex) {
                Write-Host "->$($menuItems[$i])" -ForegroundColor Yellow
            } else {
                Write-Host " $($menuItems[$i])"
            }
        }

        Write-Host "----------------" -ForegroundColor Green
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

        switch ($key.VirtualKeyCode) {
            38 { $selectedIndex = ($selectedIndex - 1) % $menuItems.Count } # Up arrow
            40 { $selectedIndex = ($selectedIndex + 1) % $menuItems.Count } # Down arrow
            13 { # Enter key
                switch ($selectedIndex) {
                    0 { Get-CpuUsage }
                    1 { Get-MemoryUsage }
                    2 { Get-DiskUsage }
                    3 { Show-Menu }
                }
            }
        }
    }
}

function Get-CpuUsage {
    # code to get CPU usage
    Write-Host "CPU Usage: 50%" -ForegroundColor Yellow
    Read-Host "Press Enter to continue"
    Show-SystemMonitoring
}

function Get-MemoryUsage {
    # code to get memory usage
    Write-Host "Memory Usage: 75%" -ForegroundColor Yellow
    Read-Host "Press Enter to continue"
    Show-SystemMonitoring
}

function Get-DiskUsage {
    # code to get disk usage
    Write-Host "Disk Usage: 90%" -ForegroundColor Yellow
    Read-Host "Press Enter to continue"
    Show-SystemMonitoring
}

Show-Menu

