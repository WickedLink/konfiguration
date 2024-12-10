function Get-ComputerUptimeDiagnostic {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,
        
        [Parameter(Mandatory=$true)]
        [datetime]$SpecificDate,
        
        [Parameter(Mandatory=$false)]
        [System.Management.Automation.PSCredential]$Credential
    )

    # Extensive diagnostic logging function
    function Write-DiagnosticLog {
        param(
            [string]$Message,
            [string]$Type = 'Info'
        )
        
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $colorMap = @{
            'Info' = 'Cyan'
            'Warning' = 'Yellow'
            'Error' = 'Red'
            'Success' = 'Green'
        }
        
        $color = $colorMap[$Type] -as [System.ConsoleColor]
        Write-Host "[$timestamp] [$Type] $Message" -ForegroundColor $color
    }

    # Start comprehensive diagnostic process
    Write-DiagnosticLog "Starting Advanced Uptime Diagnostic for $ComputerName on $SpecificDate" -Type Info

    # Calculate the date range for the entire day
    $StartDate = $SpecificDate.Date
    $EndDate = $StartDate.AddDays(1).AddSeconds(-1)

    # Prepare session parameters
    $SessionParams = @{
        ComputerName = $ComputerName
    }
    if ($Credential) {
        $SessionParams.Credential = $Credential
    }

    try {
        # Diagnostic Step 1: Advanced Event Log Querying
        Write-DiagnosticLog "Performing Comprehensive Event Log Analysis" -Type Info

        # Multiple querying strategies
        $QueryStrategies = @(
            @{
                LogName = 'System'
                EventIDs = @(12, 6005, 6006, 6009, 1, 7)
                Strategy = 'Specific IDs'
            },
            @{
                LogName = 'System'
                EventIDs = $null  # No filter
                Strategy = 'All System Events'
            },
            @{
                LogName = 'Application'
                EventIDs = $null
                Strategy = 'Application Log'
            }
        )

        $AllRetrievedEvents = @()

        foreach ($strategy in $QueryStrategies) {
            Write-DiagnosticLog "Trying Strategy: $($strategy.Strategy)" -Type Info

            $queryParams = @{
                ComputerName = $ComputerName
                LogName = $strategy.LogName
                StartTime = $StartDate
                EndTime = $EndDate
            }

            # Add event ID filter if specified
            if ($strategy.EventIDs) {
                $queryParams.Add('ID', $strategy.EventIDs)
            }

            try {
                $events = Get-WinEvent @queryParams -ErrorAction Stop
                
                if ($events) {
                    Write-DiagnosticLog "Found $($events.Count) events using $($strategy.Strategy)" -Type Success
                    $AllRetrievedEvents += $events
                }
            }
            catch {
                Write-DiagnosticLog "No events found with $($strategy.Strategy): $($_.Exception.Message)" -Type Warning
            }
        }

        # Display retrieved events
        if ($AllRetrievedEvents) {
            Write-DiagnosticLog "Total Events Retrieved: $($AllRetrievedEvents.Count)" -Type Success
            
            # Group and display events
            $GroupedEvents = $AllRetrievedEvents | Group-Object Id | Sort-Object Count -Descending
            
            foreach ($group in $GroupedEvents) {
                Write-Host "Event ID $($group.Name): $($group.Count) events" -ForegroundColor Green
                # Display a few sample events
                $group.Group | Select-Object -First 3 | Format-Table TimeCreated, Id, Message -AutoSize
            }
        }
        else {
            Write-DiagnosticLog "No events retrieved across all strategies" -Type Error
        }

        # Diagnostic Step 2: Alternative System Information Gathering
        Write-DiagnosticLog "Gathering System Information Through Alternative Methods" -Type Info
        
        $SystemInfo = Invoke-Command @SessionParams -ScriptBlock {
            # Retrieve system boot information
            $os = Get-CimInstance Win32_OperatingSystem
            $lastBootUpTime = $os.LastBootUpTime
            
            # Check event log configurations
            $systemLogConfig = Get-WinEvent -ListLog System
            
            return @{
                LastBootTime = $lastBootUpTime
                OSName = $os.Caption
                BuildNumber = $os.BuildNumber
                LogMaxSize = $systemLogConfig.MaximumSizeInBytes
                LogFileMode = $systemLogConfig.LogMode
            }
        }

        # Display System Information
        Write-Host "`nSystem Details:" -ForegroundColor Magenta
        $SystemInfo.GetEnumerator() | ForEach-Object {
            Write-Host "$($_.Key): $($_.Value)" -ForegroundColor Cyan
        }

        # Additional Diagnostic Recommendations
        Write-Host "`nDiagnostic Recommendations:" -ForegroundColor Yellow
        Write-Host "1. Verify Event Log Settings" -ForegroundColor Green
        Write-Host "2. Check System Log Permissions" -ForegroundColor Green
        Write-Host "3. Ensure Logging is Enabled" -ForegroundColor Green
    }
    catch {
        Write-DiagnosticLog "Critical Diagnostic Error: $($_.Exception.Message)" -Type Error
        Write-DiagnosticLog "Detailed Error: $($_.Exception.ToString())" -Type Error
    }
}

# Main script
# Read computer list from file
$ComputerList = Get-Content "C:\inst\ComputerList_all.txt"

# Display available computers
Write-Host "Available Computers:" -ForegroundColor Blue
for ($i = 0; $i -lt $ComputerList.Count; $i++) {
    Write-Host "$($i + 1). $($ComputerList[$i])" -ForegroundColor Green
}

# Select computer
$ComputerChoice = Read-Host "Enter the number of the computer you want to check"
$SelectedComputer = $ComputerList[$ComputerChoice - 1]

# Get specific date
$SpecificDate = Read-Host "Enter the date to check (MM/dd/yyyy)"

# Call the function (assumes $cred is already set up)
Get-ComputerUptimeDiagnostic -ComputerName $SelectedComputer -SpecificDate $SpecificDate -Credential $cred
