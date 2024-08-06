$subnet = "192.168.1"
$range = 1..254

$jobs = $range | ForEach-Object {
    $ip = "$subnet.$_"
    Start-Job -ScriptBlock {
        function Resolve-HostnameAdvanced {
            param($IP)
            try {
                return [System.Net.Dns]::GetHostEntry($IP).HostName
            } catch {
                try {
                    $output = nbtstat -A $IP | Select-String "NetBIOS"
                    if ($output -match "<00>\s+UNIQUE\s+(\S+)") {
                        return $matches[1]
                    }
                } catch {}
            }
            return "Unable to resolve"
        }

        if (Test-Connection -ComputerName $args[0] -Count 1 -Quiet) {
            $hostname = Resolve-HostnameAdvanced -IP $args[0]
            [PSCustomObject]@{
                IP = $args[0]
                Hostname = $hostname
                Status = "Online"
            }
        }
    } -ArgumentList $ip
}

$results = $jobs | Wait-Job | Receive-Job

$onlineComputers = $results | Where-Object { $_ -ne $null } | Sort-Object IP

# Display the results
Write-Host "Found computers:"
$onlineComputers | Format-Table -AutoSize

# List of computer names (excluding 'Unable to resolve')
$computerNames = $onlineComputers | Where-Object { $_.Hostname -ne "Unable to resolve" } | Select-Object -ExpandProperty Hostname

Write-Host "`nResolved computer names:"
$computerNames | ForEach-Object { Write-Host $_ }

# Ask if user wants to save to a file
$saveToFile = Read-Host "Do you want to save the computer names to a text file? (Y/N)"

if ($saveToFile -eq "Y" -or $saveToFile -eq "y") {
    $filePath = Read-Host "Enter the file path to save the computer names (e.g., C:\ComputerNames.txt)"
    $computerNames | Out-File -FilePath $filePath
    Write-Host "Computer names have been saved to $filePath"
}