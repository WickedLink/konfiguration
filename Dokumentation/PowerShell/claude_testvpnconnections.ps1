# VPN Connection Tester Script
# Tests connectivity between multiple servers in both directions
# Supports PowerShell 5 and 7

Using module Microsoft.PowerShell.Utility

param (
    [string]$ServersFile = "c:\inst\computerlist_servers.txt",
    [string]$OutputFile = "c:\inst\connection_results_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv",
    [int]$PingCount = 2
)

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

# Function to test connection between servers
function Test-InterServerConnection {
    param(
        [string]$SourceServer,
        [string]$DestServer,
        [int]$PingCount = 2,
        [System.Management.Automation.PSCredential]$Credential = $null
    )

    $connectionResult = @{
        SourceServer = $SourceServer
        DestServer = $DestServer
        Ping = $false
        PingTime = $null
        WinRM = $false
        ErrorDetails = $null
    }

    try {
        # Use Invoke-Command to run connectivity tests from the source server
        $testResult = Invoke-Command -ComputerName $SourceServer -Credential $Credential -ScriptBlock {
            param($DestServer, $PingCount)
            
            $pingResults = @{
                Ping = $false
                PingTime = $null
                WinRM = $false
            }

            # Ping Test
            try {
                $pingResult = Test-Connection -ComputerName $DestServer -Count $PingCount -ErrorAction Stop
                $pingResults.Ping = $true
                # Calculate average ping time
                $pingResults.PingTime = ($pingResult | Measure-Object -Property ResponseTime -Average).Average
            }
            catch {
                $pingResults.Ping = $false
            }

            # WinRM Test
            try {
                $winrmTest = Test-WSMan -ComputerName $DestServer -ErrorAction Stop
                $pingResults.WinRM = $true
            }
            catch {
                $pingResults.WinRM = $false
            }

            return $pingResults
        } -ArgumentList $DestServer, $PingCount

        # Update connection result with test results
        $connectionResult.Ping = $testResult.Ping
        $connectionResult.PingTime = $testResult.PingTime
        $connectionResult.WinRM = $testResult.WinRM

        # Verbose output
        Write-Host "`nConnection Test: $SourceServer → $DestServer" -ForegroundColor Yellow
        if ($testResult.Ping) {
            Write-Host "✓ Ping successful: " -NoNewline -ForegroundColor Green
            Write-Host "$($testResult.PingTime)ms" -ForegroundColor Cyan
        } else {
            Write-Host "✗ Ping failed" -ForegroundColor Red
        }

        if ($testResult.WinRM) {
            Write-Host "✓ WinRM connection successful" -ForegroundColor Green
        } else {
            Write-Host "✗ WinRM connection failed" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ Error testing connection from $SourceServer to $DestServer" -ForegroundColor Red
        $connectionResult.ErrorDetails = $_.Exception.Message
        $connectionResult.Ping = $false
        $connectionResult.WinRM = $false
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
    Write-ColorHeader "Inter-Server VPN Connection Tester" "Cyan"

    # Results array to collect all connection tests
    $allResults = @()

    # Test connections between all servers
    for ($i = 0; $i -lt $servers.Count; $i++) {
        for ($j = 0; $j -lt $servers.Count; $j++) {
            if ($i -ne $j) {
                # If $cred is defined externally, it will be used here
                $result = Test-InterServerConnection -SourceServer $servers[$i] -DestServer $servers[$j] -PingCount $PingCount -Credential $cred
                
                # Ensure result is not null before adding
                if ($result) {
                    $allResults += $result
                }
            }
        }
    }

    # Summary Statistics
    Write-ColorHeader "Connection Summary" "Green"
    $successfulPings = ($allResults | Where-Object { $_.Ping }).Count
    $successfulWinRM = ($allResults | Where-Object { $_.WinRM }).Count
    $totalTests = $allResults.Count

    Write-Host "Total Connection Tests: " -NoNewline
    Write-Host $totalTests -ForegroundColor Cyan
    Write-Host "Successful Pings: " -NoNewline
    Write-Host "$successfulPings / $totalTests" -ForegroundColor $(if($successfulPings -eq $totalTests){'Green'}else{'Yellow'})
    Write-Host "Successful WinRM Connections: " -NoNewline
    Write-Host "$successfulWinRM / $totalTests" -ForegroundColor $(if($successfulWinRM -eq $totalTests){'Green'}else{'Yellow'})

    # Export results to CSV
    $allResults | Export-Csv -Path $OutputFile -NoTypeInformation
    Write-Host "`nResults exported to: " -NoNewline
    Write-Host $OutputFile -ForegroundColor Green
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Error Details: $($_.ScriptStackTrace)" -ForegroundColor Red
}
