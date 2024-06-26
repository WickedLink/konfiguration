# Pfad zur Datei mit der Liste der Remote-Rechner
$computerListPath = "C:\inst\ComputerList.txt"
# Pfad zur allgemeinen Protokolldatei
$logFilePath = "C:\inst\LogFile.txt"
# Pfad zur Protokolldatei für nicht erreichbare Rechner
$unreachableLogFilePath = "C:\inst\UnreachableLogFile.txt"
# Pfad zur Protokolldatei für Rechner ohne aktiviertes PowerShell-Remoting
$noRemotingLogFilePath = "C:\inst\NoRemotingLogFile.txt"
# Pfad zur Erfolgsprotokolldatei
$successLogFilePath = "C:\inst\SuccessLogFile.txt"
# Pfad zur Fehlerprotokolldatei
$errorLogFilePath = "C:\inst\ErrorLogFile.txt"
# Pfad zur Gesamtbericht-Datei
$summaryLogFilePath = "C:\inst\SummaryLogFile.txt"

# Liste der Rechner einlesen
$computers = Get-Content -Path $computerListPath

# Sicherstellen, dass die Protokolldateien leer sind
Clear-Content -Path $logFilePath
Clear-Content -Path $unreachableLogFilePath
Clear-Content -Path $noRemotingLogFilePath
Clear-Content -Path $successLogFilePath
Clear-Content -Path $errorLogFilePath
Clear-Content -Path $summaryLogFilePath

foreach ($computer in $computers) {
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Überprüfe $computer..."
    Write-Output $logMessage
    Add-Content -Path $logFilePath -Value $logMessage
    
    # Überprüfen, ob der Remote-Rechner erreichbar ist
    if (Test-Connection -ComputerName $computer -Count 1 -Quiet) {
        $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $computer ist erreichbar."
        Write-Output $logMessage
        Add-Content -Path $logFilePath -Value $logMessage
        
        # Überprüfen, ob PowerShell-Remoting aktiviert ist
        try {
            Test-WSMan -ComputerName $computer -ErrorAction Stop
            $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - PowerShell-Remoting ist auf dem Remote-Rechner $computer aktiviert."
            Write-Output $logMessage
            Add-Content -Path $logFilePath -Value $logMessage
            Add-Content -Path $successLogFilePath -Value "$computer"
        } catch {
            $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - PowerShell-Remoting ist auf dem Remote-Rechner $computer nicht aktiviert. Versuche, es zu aktivieren..."
            Write-Output $logMessage
            Add-Content -Path $logFilePath -Value $logMessage

            try {
                # Aktivieren von PowerShell-Remoting
                Invoke-Command -ComputerName $computer -ScriptBlock {
                    Enable-PSRemoting -Force
                } -Credential (Get-Credential) -ErrorAction Stop
                
                $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - PowerShell-Remoting wurde auf dem Remote-Rechner $computer aktiviert."
                Write-Output $logMessage
                Add-Content -Path $logFilePath -Value $logMessage
                Add-Content -Path $successLogFilePath -Value "$computer"
            } catch {
                $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - PowerShell-Remoting konnte auf dem Remote-Rechner $computer nicht aktiviert werden."
                Write-Output $logMessage
                Add-Content -Path $logFilePath -Value $logMessage
                Add-Content -Path $noRemotingLogFilePath -Value "$computer"
                Add-Content -Path $errorLogFilePath -Value "$computer"
            }
        }
    } else {
        $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $computer ist nicht erreichbar."
        Write-Output $logMessage
        Add-Content -Path $logFilePath -Value $logMessage
        Add-Content -Path $unreachableLogFilePath -Value "$computer"
        Add-Content -Path $errorLogFilePath -Value "$computer"
    }
}

# Abschlussnachricht
$finalMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Protokollierung abgeschlossen. Ergebnisse finden Sie unter $logFilePath."
Write-Output $finalMessage
Add-Content -Path $logFilePath -Value $finalMessage

# Zusammenfassung der Ergebnisse
$summaryMessage = @"
$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Gesamtbericht:
------------------------------------------------------------
Erfolgreich überprüfte Rechner:
$(Get-Content -Path $successLogFilePath)

Nicht erreichbare Rechner:
$(Get-Content -Path $unreachableLogFilePath)

Rechner ohne aktiviertes PowerShell-Remoting:
$(Get-Content -Path $noRemotingLogFilePath)

Fehlgeschlagene Versuche:
$(Get-Content -Path $errorLogFilePath)
------------------------------------------------------------
"@

Write-Output $summaryMessage
Add-Content -Path $summaryLogFilePath -Value $summaryMessage

# Informieren Sie den Benutzer über die separaten Berichte
Write-Output "Bericht über nicht erreichbare Rechner: $unreachableLogFilePath"
Write-Output "Bericht über Rechner ohne aktiviertes PowerShell-Remoting: $noRemotingLogFilePath"
Write-Output "Erfolgsbericht: $successLogFilePath"
Write-Output "Fehlerbericht: $errorLogFilePath"
Write-Output "Gesamtbericht: $summaryLogFilePath"
