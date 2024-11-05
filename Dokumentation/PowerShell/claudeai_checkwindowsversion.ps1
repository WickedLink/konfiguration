# Define the paths
$computerListPath = ".\computerlist_all.txt"
$csvOutputPath = ".\computer_inventory.csv"

# Function to write colored status messages
function Write-StatusMessage {
    param(
        [string]$Message,
        [string]$Type = "Info"
    )
    
    $colors = @{
        "Info" = "Cyan"
        "Success" = "Green"
        "Warning" = "Yellow"
        "Error" = "Red"
        "Progress" = "Magenta"
    }
    
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')]" -NoNewline -ForegroundColor Gray
    Write-Host " [$Type] " -NoNewline -ForegroundColor $colors[$Type]
    Write-Host $Message
}

# Function to create a progress bar
function Write-ProgressBar {
    param (
        [int]$Current,
        [int]$Total
    )
    $percentComplete = [math]::Round(($Current / $Total) * 100)
    $progressBar = "[" + ("=" * [math]::Floor($percentComplete/2)) + (">" * ([math]::Floor($percentComplete/2) -gt 0)) + (" " * (50 - [math]::Floor($percentComplete/2))) + "]"
    Write-Host "`r$progressBar $percentComplete%" -NoNewline
}

# Function to get computer information
function Get-ComputerDetails {
    param (
        [string]$ComputerName,
        [System.Management.Automation.PSCredential]$Credential
    )
    
    try {
        Write-StatusMessage "Testing connection to $ComputerName..." "Progress"
        
        if (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) {
            Write-StatusMessage "$ComputerName is online" "Success"
            
            # Create CIM session options
            $sessionOptions = New-CimSessionOption -Protocol DCOM
            
            # Create CIM session
            Write-StatusMessage "Establishing connection..." "Info"
            $session = New-CimSession -ComputerName $ComputerName -Credential $Credential -SessionOption $sessionOptions
            
            Write-StatusMessage "Gathering processor information..." "Info"
            $processor = Get-CimInstance -ClassName Win32_Processor -CimSession $session |
                Select-Object -First 1 Name, Manufacturer, NumberOfCores

            Write-StatusMessage "Gathering operating system information..." "Info"
            $os = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $session |
                Select-Object Caption, Version, BuildNumber, LastBootUpTime

            Write-StatusMessage "Gathering memory information..." "Info"
            $memory = Get-CimInstance -ClassName Win32_ComputerSystem -CimSession $session |
                Select-Object TotalPhysicalMemory

            Write-StatusMessage "Gathering disk information..." "Info"
            $disk = Get-CimInstance -ClassName Win32_LogicalDisk -CimSession $session -Filter "DriveType=3" |
                Select-Object DeviceID, @{Name="SizeGB";Expression={[math]::Round($_.Size/1GB, 2)}}, @{Name="FreeGB";Expression={[math]::Round($_.FreeSpace/1GB, 2)}}

            # Get BIOS information
            Write-StatusMessage "Gathering BIOS information..." "Info"
            $bios = Get-CimInstance -ClassName Win32_BIOS -CimSession $session |
                Select-Object SerialNumber, Manufacturer, SMBIOSBIOSVersion

            # Create custom object with gathered information
            $computerInfo = [PSCustomObject]@{
                ComputerName = $ComputerName
                Status = "Online"
                ProcessorName = $processor.Name
                ProcessorManufacturer = $processor.Manufacturer
                ProcessorCores = $processor.NumberOfCores
                OperatingSystem = $os.Caption
                OSVersion = $os.Version
                OSBuildNumber = $os.BuildNumber
                TotalMemoryGB = [math]::Round($memory.TotalPhysicalMemory/1GB, 2)
                SystemDrive = $disk[0].DeviceID
                TotalSpaceGB = $disk[0].SizeGB
                FreeSpaceGB = $disk[0].FreeGB
                BIOSVersion = $bios.SMBIOSBIOSVersion
                BIOSManufacturer = $bios.Manufacturer
                SerialNumber = $bios.SerialNumber
                LastBootTime = $os.LastBootUpTime
                LastChecked = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
            
            # Clean up CIM session
            Remove-CimSession -CimSession $session
            
            Write-StatusMessage "Successfully gathered all information for $ComputerName" "Success"
            return $computerInfo
        }
        else {
            Write-StatusMessage "$ComputerName is offline" "Warning"
            return [PSCustomObject]@{
                ComputerName = $ComputerName
                Status = "Offline"
                LastChecked = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }
    }
    catch {
        Write-StatusMessage "Error processing $ComputerName : $_" "Error"
        # Clean up CIM session if it exists
        if ($session) {
            Remove-CimSession -CimSession $session
        }
        return [PSCustomObject]@{
            ComputerName = $ComputerName
            Status = "Error"
            ErrorMessage = $_.Exception.Message
            LastChecked = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
    }
}

# Main script
try {
    Write-Host "`n=== Computer Inventory Script ===" -ForegroundColor Cyan
    Write-Host "Starting inventory process at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n" -ForegroundColor Cyan
    
    # Check if computers list exists
    if (-not (Test-Path $computerListPath)) {
        throw "Computer list file not found at $computerListPath"
    }

    # Read computer list
    $computers = Get-Content $computerListPath
    Write-StatusMessage "Found $($computers.Count) computers in list" "Info"

    # Initialize results array
    $results = @()

    # Load existing CSV if it exists
    if (Test-Path $csvOutputPath) {
        Write-StatusMessage "Loading existing inventory data..." "Info"
        $existingData = Import-Csv $csvOutputPath
        
        # Process only offline computers from previous runs
        $offlineComputers = $existingData | Where-Object { $_.Status -eq "Offline" } | Select-Object -ExpandProperty ComputerName
        $onlineComputers = $existingData | Where-Object { $_.Status -ne "Offline" }
        
        # Add online computers to results
        $results += $onlineComputers
        
        # Update computers list to only check previously offline ones
        $computers = $computers | Where-Object { $offlineComputers -contains $_ }
        Write-StatusMessage "Found $($computers.Count) previously offline computers to check" "Info"
    }

    # Process each computer
    $currentComputer = 0
    foreach ($computer in $computers) {
        $currentComputer++
        Write-Host "`n"
        Write-StatusMessage "Processing computer $currentComputer of $($computers.Count)" "Progress"
        Write-ProgressBar -Current $currentComputer -Total $computers.Count
        
        $computerInfo = Get-ComputerDetails -ComputerName $computer -Credential $cred
        $results += $computerInfo
    }

    Write-Host "`n"
    Write-StatusMessage "Saving results to CSV..." "Info"
    # Export results to CSV
    $results | Export-Csv -Path $csvOutputPath -NoTypeInformation -Force

    Write-StatusMessage "Inventory completed successfully. Results saved to $csvOutputPath" "Success"
    Write-StatusMessage "Total computers processed: $($computers.Count)" "Info"
    Write-StatusMessage "Online computers: $($results | Where-Object { $_.Status -eq 'Online' } | Measure-Object | Select-Object -ExpandProperty Count)" "Success"
    Write-StatusMessage "Offline computers: $($results | Where-Object { $_.Status -eq 'Offline' } | Measure-Object | Select-Object -ExpandProperty Count)" "Warning"
    Write-StatusMessage "Errors encountered: $($results | Where-Object { $_.Status -eq 'Error' } | Measure-Object | Select-Object -ExpandProperty Count)" "Error"
}
catch {
    Write-StatusMessage "A critical error occurred: $_" "Error"
}
finally {
    Write-Host "`nScript completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
}