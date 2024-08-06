$subnet = "192.168.1"
$range = 1..254

Write-Host "Starting network scan on subnet $subnet.0/24..." -ForegroundColor Cyan

$jobs = $range | ForEach-Object {
    $ip = "$subnet.$_"
    Write-Host "Initiating scan for IP: $ip" -ForegroundColor Gray
    Start-Job -ScriptBlock {
        function Resolve-HostnameAdvanced {
            param($IP)
            Write-Host "  Attempting to resolve hostname for $IP..." -ForegroundColor Gray
            try {
                $hostname = [System.Net.Dns]::GetHostEntry($IP).HostName
                Write-Host "    Hostname resolved via DNS: $hostname" -ForegroundColor Green
                return $hostname
            } catch {
                Write-Host "    DNS resolution failed, trying NetBIOS..." -ForegroundColor Yellow
                try {
                    $output = nbtstat -A $IP | Select-String "NetBIOS"
                    if ($output -match "<00>\s+UNIQUE\s+(\S+)") {
                        $hostname = $matches[1]
                        Write-Host "    Hostname resolved via NetBIOS: $hostname" -ForegroundColor Green
                        return $hostname
                    }
                } catch {
                    Write-Host "    NetBIOS resolution failed" -ForegroundColor Red
                }
            }
            Write-Host "    Unable to resolve hostname" -ForegroundColor Red
            return "Unable to resolve"
        }

        if (Test-Connection -ComputerName $args[0] -Count 1 -Quiet) {
            Write-Host "  $($args[0]) is online. Resolving hostname..." -ForegroundColor Green
            $hostname = Resolve-HostnameAdvanced -IP $args[0]
            [PSCustomObject]@{
                IP = $args[0]
                Hostname = $hostname
                Status = "Online"
            }
        } else {
            Write-Host "  $($args[0]) is offline or not responding." -ForegroundColor Red
        }
    } -ArgumentList $ip
}

Write-Host "`nWaiting for all scans to complete..." -ForegroundColor Cyan
$results = $jobs | Wait-Job | Receive-Job

$onlineComputers = $results | Where-Object { $_ -ne $null } | Sort-Object IP

Write-Host "`nScan completed. Displaying results:" -ForegroundColor Cyan
$onlineComputers | Format-Table -AutoSize

$computerNames = $onlineComputers | Where-Object { $_.Hostname -ne "Unable to resolve" } | Select-Object -ExpandProperty Hostname

Write-Host "`nResolved computer names:" -ForegroundColor Cyan
if ($computerNames) {
    $computerNames | ForEach-Object { Write-Host $_ -ForegroundColor Green }
} else {
    Write-Host "No hostnames were successfully resolved." -ForegroundColor Yellow
}

$saveToFile = Read-Host "`nDo you want to save the computer names to a text file? (Y/N)"

if ($saveToFile -eq "Y" -or $saveToFile -eq "y") {
    $filePath = Read-Host "Enter the file path to save the computer names (e.g., C:\ComputerNames.txt)"
    $computerNames | Out-File -FilePath $filePath
    Write-Host "Computer names have been saved to $filePath" -ForegroundColor Green
} else {
    Write-Host "Computer names were not saved to a file." -ForegroundColor Yellow
}

Write-Host "`nScript execution completed." -ForegroundColor Cyan
