$ipRange = "192.168.1.1-192.168.1.254"

$ipRangeArray = $ipRange -split '-'
$start = [ipaddress]$ipRangeArray[0]
$end = [ipaddress]$ipRangeArray[1]

$startInt = [int]($start.GetAddressBytes()[0]) * 16777216 + [int]($start.GetAddressBytes()[1]) * 65536 + [int]($start.GetAddressBytes()[2]) * 256 + [int]($start.GetAddressBytes()[3])
$endInt = [int]($end.GetAddressBytes()[0]) * 16777216 + [int]($end.GetAddressBytes()[1]) * 65536 + [int]($end.GetAddressBytes()[2]) * 256 + [int]($end.GetAddressBytes()[3])

for ($i = $startInt; $i -le $endInt; $i++) {
    $byte1 = ($i -band 0xFF000000) -shr 24
    $byte2 = ($i -band 0x00FF0000) -shr 16
    $byte3 = ($i -band 0x0000FF00) -shr 8
    $byte4 = $i -band 0x000000FF
    $ipAddress = "$byte1.$byte2.$byte3.$byte4"
    Write-Host "Pinging $ipAddress..."

    if (Test-Connection -ComputerName $ipAddress -Count 1 -Quiet) {
        Write-Host "  $ipAddress is reachable"
        try {
            $computerName = (Resolve-DnsName -Name $ipAddress -Type PTR).NameHost
            Write-Host "  Computer name: $computerName"
        } catch {
            Write-Host "  Unable to retrieve computer name"
        }
    }
}


$ipRange = "192.168.1.1-192.168.1.254"
$computerNames = @()

$ipRangeArray = $ipRange -split '-'
$start = [ipaddress]$ipRangeArray[0]
$end = [ipaddress]$ipRangeArray[1]

$startInt = [int]($start.GetAddressBytes()[0]) * 16777216 + [int]($start.GetAddressBytes()[1]) * 65536 + [int]($start.GetAddressBytes()[2]) * 256 + [int]($start.GetAddressBytes()[3])
$endInt = [int]($end.GetAddressBytes()[0]) * 16777216 + [int]($end.GetAddressBytes()[1]) * 65536 + [int]($end.GetAddressBytes()[2]) * 256 + [int]($end.GetAddressBytes()[3])

for ($i = $startInt; $i -le $endInt; $i++) {
    $byte1 = ($i -band 0xFF000000) -shr 24
    $byte2 = ($i -band 0x00FF0000) -shr 16
    $byte3 = ($i -band 0x0000FF00) -shr 8
    $byte4 = $i -band 0x000000FF
    $ipAddress = "$byte1.$byte2.$byte3.$byte4"
    Write-Host "Pinging $ipAddress..."

    if (Test-Connection -ComputerName $ipAddress -Count 1 -Quiet) {
        Write-Host "  $ipAddress is reachable"
        try {
            $computerName = (Resolve-DnsName -Name $ipAddress -Type PTR).NameHost
            Write-Host "  Computer name: $computerName"
            $computerNames += $computerName
        } catch {
            Write-Host "  Unable to retrieve computer name"
        }
    }
}

Write-Host "Retrieved computer names:"
$computerNames | ForEach-Object { Write-Host "  $_" }

##########################################

$ipRange = "192.168.1.1-192.168.1.254"
$computerNames = @()

$startTime = Get-Date
Write-Host "Scan started at $startTime"

$ipRangeArray = $ipRange -split '-'
$start = [ipaddress]$ipRangeArray[0]
$end = [ipaddress]$ipRangeArray[1]

$startInt = [int]($start.GetAddressBytes()[0]) * 16777216 + [int]($start.GetAddressBytes()[1]) * 65536 + [int]($start.GetAddressBytes()[2]) * 256 + [int]($start.GetAddressBytes()[3])
$endInt = [int]($end.GetAddressBytes()[0]) * 16777216 + [int]($end.GetAddressBytes()[1]) * 65536 + [int]($end.GetAddressBytes()[2]) * 256 + [int]($end.GetAddressBytes()[3])

for ($i = $startInt; $i -le $endInt; $i++) {
    $byte1 = ($i -band 0xFF000000) -shr 24
    $byte2 = ($i -band 0x00FF0000) -shr 16
    $byte3 = ($i -band 0x0000FF00) -shr 8
    $byte4 = $i -band 0x000000FF
    $ipAddress = "$byte1.$byte2.$byte3.$byte4"
    Write-Host "Pinging $ipAddress..."

    if (Test-Connection -ComputerName $ipAddress -Count 1 -Quiet) {
        Write-Host "  $ipAddress is reachable"
        try {
            $fqdn = (Resolve-DnsName -Name $ipAddress -Type PTR).NameHost
            $hostname = $fqdn.Split('.')[0]
            Write-Host "  Computer name: $hostname"
            $computerNames += $hostname
        } catch {
            Write-Host "  Unable to retrieve computer name"
        }
    }
}

$endTime = Get-Date
Write-Host "Scan completed at $endTime"

$executionTime = $endTime - $startTime
Write-Host "Scan took $($executionTime.TotalSeconds) seconds to complete"

Write-Host "Retrieved computer names:"
$computerNames | ForEach-Object { Write-Host "  $_" }


