$ipRange = "192.168.1.43-192.168.1.48"

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
            $computerName = (Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ipAddress).Name
            Write-Host "  Computer name: $computerName"
        } catch {
            Write-Host "  Unable to retrieve computer name"
        }
    }
}
