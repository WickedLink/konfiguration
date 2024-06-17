# Anmeldeinformationen in Variable speichern
$cred = Get-Credential

# prüfen, ob Powershell-Remoting aktiv
Test-WSMan
Test-WSMan kgt-mi-ps -Authentication Negotiate -Credential $cred
Get-NetTCPConnection -LocalPort 5985
Test-NetConnection -ComputerName kgt-mi-ps -Port 5985

# installierte Software auflisten
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Sort Displayname | Select-Object DisplayName, DisplayVersion, InstallDate, Publisher
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
$session = New-PSSession -ComputerName kgt-mi-ps -Credential $cred
Invoke-Command -Session $session -ScriptBlock {hostname}

$computer = 'kgt-mi-fel841k'  
gwmi win32_LogonSession -Computer $computer -Filter 'LogonType=2 or LogonType=10' | %{  
    gwmi -ComputerName $computer -Query "Associators of {Win32_LogonSession.LogonId=$($_.LogonId)} Where AssocClass=Win32_LoggedOnUser Role=Dependent" | select -Expand Name  
}

# installierte Software auflisten
Get-WmiObject win32_product -ComputerName kgt-mi-hun868nb | Select-Object name, version

# Computername auslesen
Get-ChildItem Env:\COMPUTERNAME