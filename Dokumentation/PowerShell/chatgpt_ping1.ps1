# Zielrechner definieren (IP-Adresse oder Hostname)
$target = "192.168.1.221"

# Dauer des Tests in Minuten
$durationMinutes = 5

# Intervall zwischen den Pings in Sekunden
$pingInterval = 1

# Endzeit berechnen
$endTime = (Get-Date).AddMinutes($durationMinutes)

# Ping-Schleife
while ((Get-Date) -lt $endTime) {
    # Führe den Ping-Befehl aus und speichere das Ergebnis
    $pingResult = Test-Connection -ComputerName $target -Count 1

    # Überprüfe, ob der Ping erfolgreich war
    if ($pingResult) {
        # Zeige die Reaktionszeit an
        $latency = $pingResult.Latency
        Write-Host "[$(Get-Date)] $target ist erreichbar. Reaktionszeit: $latency ms" -ForegroundColor Green
    } else {
        Write-Host "[$(Get-Date)] $target ist nicht erreichbar." -ForegroundColor Red
    }

    # Warte das festgelegte Intervall
    Start-Sleep -Seconds $pingInterval
}

Write-Host "Test abgeschlossen." -ForegroundColor Yellow
