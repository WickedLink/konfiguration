# Define the path to the text file containing the list of computer names
$computerListPath = "C:\inst\computerlist_all.txt"

# Read the list of computers from the text file
$computers = Get-Content -Path $computerListPath

# Prompt for a specific date
$dateInput = Read-Host "Enter the date (yyyy-mm-dd) to check for uptime"
$date = Get-Date $dateInput

# Define the start and end time for the specified date
$startTime = $date.Date
$endTime = $date.Date.AddDays(1)

# Initialize an array to hold the results
$results = @()

# Loop through each computer in the list
foreach ($computer in $computers) {
    try {
        # Get startup and shutdown events for the specified date
        $startupEvents = Get-WinEvent -ComputerName $computer -FilterHashtable @{LogName='System'; Id=6005; StartTime=$startTime; EndTime=$endTime} -Credential $cred
        $shutdownEvents = Get-WinEvent -ComputerName $computer -FilterHashtable @{LogName='System'; Id=6006, 6008, 1074; StartTime=$startTime; EndTime=$endTime} -Credential $cred

        # Combine the events and sort them by time
        $allEvents = $startupEvents + $shutdownEvents | Sort-Object TimeCreated

        # Initialize variables to track uptime
        $uptimePeriods = @()
        $lastStartup = $null

        # Process the events to determine uptime periods
        foreach ($event in $allEvents) {
            if ($event.Id -eq 6005) {
                # Record the startup time
                $lastStartup = $event.TimeCreated
            } elseif ($event.Id -eq 6006 -or $event.Id -eq 6008 -or $event.Id -eq 1074) {
                # Record the shutdown time if there was a previous startup
                if ($lastStartup) {
                    $uptimePeriods += [PSCustomObject]@{
                        ComputerName = $computer
                        StartTime     = $lastStartup
                        EndTime       = $event.TimeCreated
                    }
                    $lastStartup = $null  # Reset for the next uptime period
                }
            }
        }

        # Add the results to the main results array
        $results += $uptimePeriods
    } catch {
        Write-Host "Failed to retrieve events from ${computer}: $_"
    }
}

# Output the results
if ($results.Count -gt 0) {
    $results | Format-Table -AutoSize
} else {
    Write-Host "No uptime data found for the specified date."
}
