# Array für alle pingbaren Geräte            
$alleOnlineGeraete = @()            
            
# Array für alle NICHT pingbaren Geräte            
$alleOfflineGeraete = @()            
            
# Ganzes Netzwerksegment von 1 bis 255            
$alleIPs = (1..255)            
            
# Auswahl der Netzwerkkarte bzw. IP Adresse die für den Ping verwendet werden soll            
$gewaehlteIP = Get-NetIPAddress | where {$_.IPAddress -like "192.168.*" -or $_.IPAddress -like "10.*" `
-or $_.IPAddress -like "172.16.*"} | Sort-Object InterfaceIndex | select IPAddress |  Out-GridView -Title "Wähle die Netzwerkkarte" -PassThru            
            
# Teilen der gewählten IP Adresse, damit nur die ersten 3 Oktetts verwendet werden            
$splitIP = $gewaehlteIP.IPAddress.Split(".")[0..2] -join "."            
            
# Am Ende der 3 Oktetts noch ein Punkt (.) anhängen            
$splitIP += "."            
            
# Testen der Verbindung aller IPs im Bereich $alleIPs            
foreach ($ip in $alleIPs)            
{            
    # Generieren der IP Adressen bzw. des letzten Oktetts und zusammensetzen            
    $testIP = $splitIP + $ip            
            
    # Testen der Verbindung mit 2 Pings (-Count 2) mit Rückgabe $true oder $false (-Quiet)            
    if (Test-Connection -Count 1 -BufferSize 2 -Quiet $testIP -TimeoutSeconds 1)             
        {            
            # Schreiben bei Erfolg            
            Write-Output "$testIP Online"            
                    
            # Array ergänzen mit dem Online Gerät            
            $alleOnlineGeraete += $testIP            
        }             
    else             
        {            
            # Schreiben bei Misserfolg            
            Write-Output "$testIP Offline"            
                        
            # Array ergänzen mit dem Offline Gerät            
            $alleOfflineGeraete += $testIP            
        }            
}            
            
# Ausgabe der Online Geräte            
"Online sind:"            
$alleOnlineGeraete             
            
# Ausgabe der Offline Geräte            
"Offline sind:"            
$alleOfflineGeraete

