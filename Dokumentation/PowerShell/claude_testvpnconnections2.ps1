# VPN Connection Tester Script
# Tests connectivity between multiple servers in both directions
# Supports PowerShell 5 and 7

Using module Microsoft.PowerShell.Utility

param (
    [string]$ServersFile = "c:\inst\computerlist_servers.txt",
    [string]$OutputFile = "c:\inst\connection_results_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt",
    [int]$PingCount = 2
)

# Function to create a colorful header
function Write-ColorHeader {
    param([string]$Text, [string]$Color = 'Green')
    
    $repeatChar = '='
    $padding = 60
    $header = $repeatChar * $padding
    
    $headerText = "".PadLeft(($padding + $Text.Length) / 2, $repeatChar)
    $colorOutput = @"
$header
$headerText $Text
$header
"@

    return $colorOutput
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

        return $connectionResult
    }
    catch {
        $connectionResult.ErrorDetails = $_.Exception.Message
        $connectionResult.Ping = $false
        $connectionResult.WinRM = $false
        return $connectionResult
    }
}

# Main Script Execution
try {
    # Read servers from file
    $servers = Get-Content -Path $ServersFile -ErrorAction Stop

    # Validate servers file
    if ($servers.Count -lt 2) {
        throw "At least two servers are required in the servers file."
    }

    # Results array to collect all connection tests
    $allResults = @()

    # Prepare output content
    $outputContent = @()
    $outputContent += Write-ColorHeader "Inter-Server VPN Connection Tester" "Cyan"

    # Test connections between all servers
    $totalTests = 0
    $successfulPings = 0
    $successfulWinRM = 0

    for ($i = 0; $i -lt $servers.Count; $i++) {
        for ($j = 0; $j -lt $servers.Count; $j++) {
            if ($i -ne $j) {
                # Test connection
                $result = Test-InterServerConnection -SourceServer $servers[$i] -DestServer $servers[$j] -PingCount $PingCount

                # Add to results
                $allResults += $result
                $totalTests++

                # Prepare output text
                $connectionText = "`nConnection Test: $($result.SourceServer) → $($result.DestServer)"
                $outputContent += $connectionText

                if ($result.Ping) {
                    $outputContent += "✓ Ping successful: $($result.PingTime)ms"
                    $successfulPings++
                } else {
                    $outputContent += "✗ Ping failed"
                }

                if ($result.WinRM) {
                    $outputContent += "✓ WinRM connection successful"
                    $successfulWinRM++
                } else {
                    $outputContent += "✗ WinRM connection failed"
                }
            }
        }
    }

    # Add Summary Section
    $outputContent += Write-ColorHeader "Connection Summary" "Green"
    $outputContent += "Total Connection Tests: $totalTests"
    $outputContent += "Successful Pings: $successfulPings / $totalTests"
    $outputContent += "Successful WinRM Connections: $successfulWinRM / $totalTests"

    # Write to text file
    $outputContent | Out-File -FilePath $OutputFile -Encoding UTF8
    Write-Host "`nResults exported to: $OutputFile" -ForegroundColor Green
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Error Details: $($_.ScriptStackTrace)" -ForegroundColor Red
}
