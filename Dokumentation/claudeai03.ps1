$subnet = "192.168.1"
$range = 1..254

$jobs = $range | ForEach-Object {
    $ip = "$subnet.$_"
    Start-Job -ScriptBlock {
        if (Test-Connection -ComputerName $args[0] -Count 1 -Quiet) {
            try {
                $hostname = [System.Net.Dns]::GetHostEntry($args[0]).HostName
            }
            catch {
                $hostname = "Unable to resolve"
            }
            [PSCustomObject]@{
                IP = $args[0]
                Hostname = $hostname
                Status = "Online"
            }
        }
    } -ArgumentList $ip
}

$results = $jobs | Wait-Job | Receive-Job

$results | Where-Object { $_ -ne $null } | Sort-Object IP
