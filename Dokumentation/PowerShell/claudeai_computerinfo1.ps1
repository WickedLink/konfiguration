# Read computer names from a text file
$computers = Get-Content -Path "C:\inst\computerlist.txt"

# Define the function to get hardware info
function Get-HardwareInfo {
    param (
        [string]$ComputerName,
        [System.Management.Automation.PSCredential]$Credential
    )

    $scriptBlock = {
        try {
            $os = Get-WmiObject -Class Win32_OperatingSystem -ErrorAction Stop
            $cs = Get-WmiObject -Class Win32_ComputerSystem -ErrorAction Stop
            $proc = Get-WmiObject -Class Win32_Processor -ErrorAction Stop
            $mem = Get-WmiObject -Class Win32_PhysicalMemory -ErrorAction Stop | Measure-Object -Property Capacity -Sum
            $disk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction Stop

            [PSCustomObject]@{
                ComputerName = $env:COMPUTERNAME
                OSName = $os.Caption
                OSVersion = $os.Version
                Manufacturer = $cs.Manufacturer
                Model = $cs.Model
                Processor = $proc.Name
                Memory = "{0:N2} GB" -f ($mem.Sum / 1GB)
                Disks = ($disk | ForEach-Object { "Drive $($_.DeviceID): $("{0:N2}" -f ($_.Size / 1GB)) GB" }) -join ', '
            }
        }
        catch {
            Write-Error "Failed to retrieve information. Error: $($_.Exception.Message)"
        }
    }

    $params = @{
        ComputerName = $ComputerName
        ScriptBlock = $scriptBlock
        ErrorAction = 'Stop'
    }

    if ($Credential) {
        $params.Credential = $Credential
    }

    try {
        Invoke-Command @params
    }
    catch {
        Write-Warning "Failed to retrieve information for $ComputerName. Error: $($_.Exception.Message)"
        return $null
    }
}

# Create an empty array to store results
$results = @()

# Process each computer
foreach ($computer in $computers) {
    Write-Host "Processing $computer..." -ForegroundColor Cyan
    
    if (Test-Connection -ComputerName $computer -Count 1 -Quiet) {
        try {
            if ($cred) {
                $result = Get-HardwareInfo -ComputerName $computer -Credential $cred
            } else {
                $result = Get-HardwareInfo -ComputerName $computer
            }
            if ($result) {
                $results += $result
            }
        } catch {
            Write-Warning "An error occurred while processing ${computer}: $($_.Exception.Message)"
        }
    } else {
        Write-Warning "$computer is not reachable."
    }
}

# Output results
$results | Format-Table -AutoSize -Wrap

# Output results to HTML for eye candy
$htmlReport = $results | ConvertTo-Html -As Table -CssUri "https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" -Title "Hardware Information Report" -PreContent "<h1>Hardware Information Report</h1>" -PostContent "<p>Report generated on $(Get-Date)</p>"
$htmlReport | Out-File "HardwareReport.html"

Write-Host "Report generated and saved as HardwareReport.html" -ForegroundColor Green
