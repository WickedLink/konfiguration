# Define the path to the text file containing the list of computers
Write-Host "Setting computer list file path..." -ForegroundColor Gray
$computerListFile = "C:\inst\ComputerList_updates.txt"

# Define the credentials for elevated access (if needed)
Write-Host "Setting up credentials..." -ForegroundColor Gray
# $cred = Get-Credential -Username "YourUsername" -Password "YourPassword"

# Read the list of computers from the text file
Write-Host "Reading computer list from file..." -ForegroundColor Gray
$computers = Get-Content -Path $computerListFile

# Create a hashtable to store the results
Write-Host "Creating results hashtable..." -ForegroundColor Gray
$results = @{}

# Function to check if a computer is online
Write-Host "Defining Test-ComputerOnline function..." -ForegroundColor Gray
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

# Loop through each computer
Write-Host "Starting computer loop..." -ForegroundColor Gray
foreach ($computer in $computers) {
    Write-Host "Processing $computer..." -ForegroundColor Green

    # Check if the computer is online
    Write-Host "  Checking online status..." -ForegroundColor Gray
    $isOnline = Test-ComputerOnline -computerName $computer

    if ($isOnline) {
        # Create a new PowerShell session with elevated rights (if needed)
        Write-Host "  Setting up PowerShell session..." -ForegroundColor Gray
        $session = New-PSSession -ComputerName $computer -Credential $cred -ErrorAction SilentlyContinue

        # If the session is created successfully, retrieve hardware information
        if ($session) {
            Write-Host "  Retrieving hardware information..." -ForegroundColor Gray
            $hwInfo = Invoke-Command -Session $session -ScriptBlock {
                Write-Host "    Retrieving OS information..." -ForegroundColor Gray
                $os = Get-CimInstance -Class Win32_OperatingSystem
                Write-Host "    Retrieving CPU information..." -ForegroundColor Gray
                $cpu = Get-CimInstance -Class Win32_Processor
                Write-Host "    Retrieving RAM information..." -ForegroundColor Gray
                $mem = Get-CimInstance -Class Win32_PhysicalMemory
                Write-Host "    Retrieving disk information..." -ForegroundColor Gray
                $disk = Get-CimInstance -Class Win32_LogicalDisk -Filter "DriveType = 3"

                [PSCustomObject]@{
                    ComputerName = $env:COMPUTERNAME
                    OS           = $os.Caption
                    CPU          = $cpu.Name
                    Cores        = $cpu.NumberOfCores
                    RAM          = ($mem.Capacity / 1GB) -as [int]
                    DiskSize    = ($disk.Size / 1GB) -as [int]
                }
            }

            # Add the results to the hashtable
            Write-Host "  Adding results to hashtable..." -ForegroundColor Gray
            $results.Add($computer, $hwInfo)

            # Close the PowerShell session
            Write-Host "  Closing PowerShell session..." -ForegroundColor Gray
            $session | Remove-PSSession
        } else {
            Write-Host "  Failed to connect to $computer" -ForegroundColor Red
        }
    } else {
        Write-Host "  Computer is offline..." -ForegroundColor Red
        $results.Add($computer, "Offline")
    }
}

# Display the results with some eyecandy
Write-Host "Displaying results..." -ForegroundColor Gray
Write-Host "Hardware Information:" -ForegroundColor Cyan
Write-Host "-------------------" -ForegroundColor Cyan

$results.GetEnumerator() | ForEach-Object {
    if ($_.Value -eq "Offline") {
        Write-Host "Computer: $($._Key)" -ForegroundColor Yellow
        Write-Host "  Status: Offline" -ForegroundColor Red
        Write-Host "-------------------" -ForegroundColor Cyan
    } else {
        Write-Host "Computer: $($._Key)" -ForegroundColor Yellow
        Write-Host "  OS: $($._Value.OS)" -ForegroundColor White
        Write-Host "  CPU: $($._Value.CPU)" -ForegroundColor White
        Write-Host "  Cores: $($._Value.Cores)" -ForegroundColor White
        Write-Host "  RAM: $($._Value.RAM) GB" -ForegroundColor White
        # Write-Host "  Disk Size: $($._Value.DiskSize) GB" -ForegroundColor White
        foreach ($disk in $_.Value) {
            Write-Host "  Disk Size: $($disk.DiskSize / 1GB) GB" -ForegroundColor White
        }
        Write-Host "-------------------" -ForegroundColor Cyan
    }
}

Write-Host "Script complete!" -ForegroundColor Green
