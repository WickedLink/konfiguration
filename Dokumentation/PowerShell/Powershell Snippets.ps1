# Anmeldeinformationen in Variable speichern
$cred = Get-Credential

# prüfen, ob Powershell-Remoting aktiv
Test-WSMan
Test-WSMan kgt-mi-kri888 -Authentication Negotiate -Credential $cred
Get-NetTCPConnection -LocalPort 5985
Test-NetConnection -ComputerName kgt-mi-ps -Port 5985

# installierte Software auflisten
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Sort-Object Displayname | Select-Object DisplayName, DisplayVersion, InstallDate, Publisher
winget list

# Remotesession öffnen
Enter-PSSession kgt-mi-hun868nb -Credential $cred
Enter-PSSession kgt-mi-let863 -Credential $cred

# Remotesession verlassen
Exit-PSSession

# Prozesse anzeigen
Get-Process | Out-GridView
Get-Process
Get-Process no*

# Prozess beenden
Stop-Process -Name "notepad"

# Computer herunterfahren
Stop-Computer -Force

# Befehl in Remotesession ausführen
$session = New-PSSession -ComputerName kgt-mi-let863 -Credential $cred
Invoke-Command -Session $session -ScriptBlock {hostname}

$computer = 'kgt-mi-fel841k'  
gwmi win32_LogonSession -Computer $computer -Filter 'LogonType=2 or LogonType=10' | %{  
    gwmi -ComputerName $computer -Query "Associators of {Win32_LogonSession.LogonId=$($_.LogonId)} Where AssocClass=Win32_LoggedOnUser Role=Dependent" | select -Expand Name  
}

# installierte Software auflisten
Get-WmiObject win32_product -ComputerName kgt-mi-let863 | Select-Object name, version

# Computername auslesen
Get-ChildItem Env:\COMPUTERNAME

# Windows Uptime auslesen
(Get-Date) – (Get-CimInstance Win32_OperatingSystem -ComputerName kgt-mi-hun868nb).LastBootupTime

# Rechner umbenennen
Rename-Computer -NewName NEUER NAME

# Rechner neu starten
Restart-Computer -ComputerName kgt-mi-bar873 -Credential

# Nachricht an Computer senden
msg * /server:192.168.178.10 "Deine Nachricht"
Start-Sleep 4
msg * /server:kgt-mi-let863 /time:10 "Ahwas?"
Start-Sleep 4
msg * /server:kgt-mi-hun868nb /time:1 "Häh?"
Start-Sleep -Milliseconds 500
msg * /server:kgt-mi-let863 /time:1 "Wieso?"
Start-Sleep -Milliseconds 500
msg * /server:kgt-mi-let863 /time:1 "Warum?"


if(Test-WSMan kgt-mi-let863 -ErrorAction SilentlyContinue) {
    $fehler = "geht"
} 
else {
    $fehler = "geht nicht"
}
Write-Host 