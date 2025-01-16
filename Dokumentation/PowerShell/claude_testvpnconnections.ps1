# VPN Connection Tester Script
# Tests connectivity between multiple servers in both directions
# Supports PowerShell 7 or later

param (
    [string]$ServersFile = "servers.txt",
    [string]$OutputFile = "connection_results_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv",
    [int]$Timeout = 1000 # Ping timeout in milliseconds
)

# Import required modules
Using module @{ModuleName='Microsoft.PowerShell.Utility';ModuleVersion='7.0.0.0'}

# Function to create a colorful header
function Write-ColorHeader {
    param([string]$Text, [string]$Color = 'Green')
    
    $repeatChar = '='
    $padding = 60
    $header = $repeatChar * $padding
    
    Write-Host $header -ForegroundColor DarkGray
    Write-Host $Text.PadLeft(($padding + $Text.Length) / 2) -ForegroundColor $Color
    Write-Host $header -ForegroundColor DarkGray
}

# Function to test connection with verbose output
function Test-ServerConnection {
    param(
        [string]$SourceServer,
        [string]$DestServer,
        [int]$Timeout = 1000,
        [System.Management.Automation.PSCredential]$Credential = $null
    )

    $connectionResult = @{
        SourceServer = $SourceServer
        DestServer = $DestServer
        Ping = $false
        PingTime = $null
        WinRM = $false
        SMB = $false
        ErrorDetails = $null
    }

    # Ping Test
    try {
        $pingResult = Test-Connection -ComputerName $DestServer -Count 2 -Timeout $Timeout -ErrorAction Stop
        $connectionResult.Ping = $true
        $connectionResult.PingTime = $pingResult.Latency
        
        Write-Host "✓ Ping from $SourceServer to $DestServer: " -NoNewline -ForegroundColor Green
        Write-Host "$($pingResult.Latency)ms" -ForegroundColor Cyan
    }
    catch {
        Write-Host "✗ Ping from $SourceServer to $DestServer failed" -ForegroundColor Red
        $connectionResult.ErrorDetails = $_.Exception.Message
    }

    # WinRM Test (if credentials provided)
    if ($Credential) {
        try {
            $winrmSession = New-PSSession -ComputerName $DestServer -Credential $Credential -ErrorAction Stop
            $connectionResult.WinRM = $true
            Remove-PSSession $winrmSession
            
            Write-Host "✓ WinRM connection from $SourceServer to $DestServer successful" -ForegroundColor Green
        }
        catch {
            Write-Host "✗ WinRM connection from $SourceServer to $DestServer failed" -ForegroundColor Red
            $connectionResult.ErrorDetails = $_.Exception.Message
        }
    }

    # SMB Test
    try {
        $smbTest = Get-SmbConnection -ServerName $DestServer -ErrorAction Stop
        $connectionResult.SMB = $true
        
        Write-Host "✓ SMB connection from $SourceServer to $DestServer successful" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ SMB connection from $SourceServer to $DestServer failed" -ForegroundColor Red
    }

    return $connectionResult
}

# Main Script Execution
try {
    # Read servers from file
    $servers = Get-Content -Path $ServersFile -ErrorAction Stop

    # Validate servers file
    if ($servers.Count -lt 2) {
        throw "At least two servers are required in the servers file."
    }

    # Display script banner
    Write-ColorHeader "VPN Connection Tester" "Cyan"

    # Results array to collect all connection tests
    $allResults = @()

    # Test connections between all servers
    for ($i = 0; $i -lt $servers.Count; $i++) {
        for ($j = 0; $j -lt $servers.Count; $j++) {
            if ($i -ne $j) {
                Write-Host "`nTesting connection from $($servers[$i]) to $($servers[$j])" -ForegroundColor Yellow
                
                # If $cred is defined externally, it will be used here
                $result = Test-ServerConnection -SourceServer $servers[$i] -DestServer $servers[$j] -Timeout $Timeout -Credential $cred
                $allResults += $result
            }
        }
    }

    # Summary Statistics
    Write-ColorHeader "Connection Summary" "Green"
    $successfulPings = ($allResults | Where-Object { $_.Ping }).Count
    $successfulWinRM = ($allResults | Where-Object { $_.WinRM }).Count
    $successfulSMB = ($allResults | Where-Object { $_.SMB }).Count
    $totalTests = $allResults.Count

    Write-Host "Total Connection Tests: " -NoNewline
    Write-Host $totalTests -ForegroundColor Cyan
    Write-Host "Successful Pings: " -NoNewline
    Write-Host "$successfulPings / $totalTests" -ForegroundColor $(if($successfulPings -eq $totalTests){'Green'}else{'Yellow'})
    Write-Host "Successful WinRM Connections: " -NoNewline
    Write-Host "$successfulWinRM / $totalTests" -ForegroundColor $(if($successfulWinRM -eq $totalTests){'Green'}else{'Yellow'})
    Write-Host "Successful SMB Connections: " -NoNewline
    Write-Host "$successfulSMB / $totalTests" -ForegroundColor $(if($successfulSMB -eq $totalTests){'Green'}else{'Yellow'})

    # Export results to CSV
    $allResults | Export-Csv -Path $OutputFile -NoTypeInformation
    Write-Host "`nResults exported to: " -NoNewline
    Write-Host $OutputFile -ForegroundColor Green
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
