function Get-ComputerUptime {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,
        
        [Parameter(Mandatory=$true)]
        [datetime]$SpecificDate,
        
        [Parameter(Mandatory=$false)]
        [System.Management.Automation.PSCredential]$Credential
    )

    # Colorful header
    Write-Host "===== Advanced Computer Uptime Analysis =====" -ForegroundColor Cyan
    Write-Host "Computer: $ComputerName" -ForegroundColor Green
    Write-Host "Date: $($SpecificDate.ToShortDateString())" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Cyan

    # Calculate the date range for the entire day
    $StartDate = $SpecificDate.Date
    $EndDate = $StartDate.AddDays(1).AddSeconds(-1)

    try {
        # Multiple methods to detect system uptime
        
        # Method 1: Try specific system event logs
        $EventsToCheck = @(
            12,  # Standard startup event
            6005, # Event log service started
            6006, # Event log service stopped
            6009  # Windows version information on startup
        )

        $SystemEvents = Get-WinEvent -ComputerName $ComputerName -FilterHashtable @{
            LogName = 'System'
            ID = $EventsToCheck
            StartTime = $StartDate
            EndTime = $EndDate
        } -ErrorAction SilentlyContinue

        # Method 2: PowerShell Remoting to check system uptime
        $UptimeScript = {
            $os = Get-CimInstance Win32_OperatingSystem
            $bootTime = $os.LastBootUpTime
            $uptime = (Get-Date) - $bootTime
            return @{
                BootTime = $bootTime
                Uptime = $uptime
            }
        }

        # Prepare session parameters
        $SessionParams = @{
            ComputerName = $ComputerName
        }
        if ($Credential) {
            $SessionParams.Credential = $Credential
        }

        # Run remote command
        $RemoteUptime = Invoke-Command @SessionParams -ScriptBlock $UptimeScript

        # Verbose output of findings
        Write-Host "`n🖥️ Uptime Detection Results 🖥️" -ForegroundColor Magenta
        Write-Host "----------------------------------------" -ForegroundColor DarkGray

        # Display system events if found
        if ($SystemEvents) {
            Write-Host "🔍 Relevant System Events Found:" -ForegroundColor Green
            $SystemEvents | ForEach-Object {
                $EventMessage = switch ($_.Id) {
                    12   { "System Startup" }
                    6005 { "Event Log Service Started" }
                    6006 { "Event Log Service Stopped" }
                    6009 { "Windows Version Info" }
                    default { "Unknown Event" }
                }
                Write-Host "   • $($_.TimeCreated) - Event ID $($_.Id): $EventMessage" -ForegroundColor Cyan
            }
        }
        else {
            Write-Host "❗ No specific system events found for the given date." -ForegroundColor Yellow
        }

        # Display remote uptime information
        Write-Host "`n💻 System Uptime Details:" -ForegroundColor Green
        Write-Host "   🕒 Last Boot Time: $($RemoteUptime.BootTime)" -ForegroundColor Yellow
        Write-Host "   ⏱️ Current Uptime: $($RemoteUptime.Uptime.Days)d $($RemoteUptime.Uptime.Hours)h $($RemoteUptime.Uptime.Minutes)m" -ForegroundColor Yellow

        # Additional diagnostic information
        Write-Host "`n🔬 Diagnostic Information:" -ForegroundColor Magenta
        Write-Host "   Checked Date Range: $StartDate to $EndDate" -ForegroundColor Blue
        Write-Host "   Event IDs Checked: $($EventsToCheck -join ', ')" -ForegroundColor Blue
    }
    catch {
        Write-Host "❌ Error retrieving uptime information: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   Detailed Error: $($_.Exception.ToString())" -ForegroundColor DarkRed
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
Get-ComputerUptime -ComputerName $SelectedComputer -SpecificDate $SpecificDate -Credential $cred
