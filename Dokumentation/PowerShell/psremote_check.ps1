# Pfad zur Datei mit der Liste der Remote-Rechner
$computerListPath = "C:\Path\To\ComputerList.txt"
# Pfad zur allgemeinen Protokolldatei
$logFilePath = "C:\Path\To\LogFile.txt"
# Pfad zur Protokolldatei für nicht erreichbare Rechner
$unreachableLogFilePath = "C:\Path\To\UnreachableLogFile.txt"
# Pfad zur Protokolldatei für Rechner ohne aktiviertes PowerShell-Remoting
$noRemotingLogFilePath = "C:\Path\To\NoRemotingLogFile.txt"

# Liste der Rechner einlesen
$computers = Get-Content -Path $computerListPath

# Sicherstellen, dass die Protokolldateien leer sind
Clear-Content -Path $logFilePath
Clear-Content -Path $unreachableLogFilePath
Clear-Content -Path $noRemotingLogFilePath

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
        } catch {
            $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - PowerShell-Remoting ist auf dem Remote-Rechner $computer nicht aktiviert."
            Write-Output $logMessage
            Add-Content -Path $logFilePath -Value $logMessage
            Add-Content -Path $noRemotingLogFilePath -Value "$computer"
        }
    } else {
        $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $computer ist nicht erreichbar."
        Write-Output $logMessage
        Add-Content -Path $logFilePath -Value $logMessage
        Add-Content -Path $unreachableLogFilePath -Value "$computer"
    }
}

# Abschlussnachricht
$finalMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Protokollierung abgeschlossen. Ergebnisse finden Sie unter $logFilePath."
Write-Output $finalMessage
Add-Content -Path $logFilePath -Value $finalMessage

# Informieren Sie den Benutzer über die separaten Berichte
Write-Output "Bericht über nicht erreichbare Rechner: $unreachableLogFilePath"
Write-Output "Bericht über Rechner ohne aktiviertes PowerShell-Remoting: $noRemotingLogFilePath"
