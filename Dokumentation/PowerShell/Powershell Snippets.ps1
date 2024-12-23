# Anmeldeinformationen in Variable speichern
$cred = Get-Credential

# prüfen, ob Powershell-Remoting aktiv
Test-WSMan
Test-WSMan kgt-mi-ps -Authentication Negotiate -Credential $cred
Get-NetTCPConnection -LocalPort 5985
Test-NetConnection -ComputerName kgt-mi-ps -Port 5985

# installierte Software auflisten
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Sort-Object Displayname | Select-Object DisplayName, DisplayVersion, InstallDate, Publisher
winget list

# Remotesession öffnen
Enter-PSSession kgt-mi-bar873 -Credential $cred
Enter-PSSession kgt-mi-hun868nb -Credential $cred
Enter-PSSession kgt-mi-usr -Credential $cred

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
Get-WmiObject win32_product -ComputerName kgt-mi-let863 | Select-Object name, version

# Computername auslesen
Get-ChildItem Env:\COMPUTERNAME

# Windows Uptime auslesen
(Get-Date) – (Get-CimInstance Win32_OperatingSystem -ComputerName "kgt-mi-dem804-2").LastBootupTime
(Get-Date) – (Get-CimInstance Win32_OperatingSystem -ComputerName kgt-p-fs2).LastBootupTime

# Rechner umbenennen
Rename-Computer -NewName NEUER NAME

# dns-server herausfinden
Get-DnsClientServerAddress

# dns-server auf standard (dhcp) zurücksetzen
Set-DnsClientServerAddress -InterfaceAlias "WLAN" -ResetServerAddresses

# dns-server einstellen
# DNS-Server für den Adapter "Ethernet" ändern
$interfaceAlias = "Ethernet"
$dnsServers = "8.8.8.8", "8.8.4.4"
$dnsServers = "192.168.1.7", "192.168.115.2", "8.8.8.8"

Set-DnsClientServerAddress -InterfaceAlias $interfaceAlias -ServerAddresses $dnsServers

# ipconfig alternativen
Get-NetIPAddress
Get-NetIPAddress -InterfaceAlias ethernet -AddressFamily ipv4
Get-NetIPConfiguration
Get-NetAdapter
Get-NetRoute




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

msg * /server:<remote_computer_name> /time:30 "Hello from PowerShell!`nThis is a new line."
msg * /server:kgt-mi-ps /time:30 "Hello from PowerShell!`nThis is a new line."

# prüfen, ob Powershell-Remoting aktiviert ist 1
if(Test-WSMan kgt-mi-ps -ErrorAction SilentlyContinue) {
    $fehler = "geht"
} 
else {
    $fehler = "geht nicht"
}
Write-Host $fehler

# prüfen, ob Powershell-Remoting aktiviert ist 2
[bool](Test-WSMan -ComputerName 'kgt-mi-ps' -ErrorAction SilentlyContinue)

# prüfen, ob Powershell-Remoting aktiviert ist 3
if ([bool](Test-WSMan -ComputerName 'kgt-mi-ps' -ErrorAction SilentlyContinue)) {
    Write-Host "geht"
}
else {
    Write-Host "geht nicht"
}

# testen, ob Rechner erreichbar
if ( Test-Connection -ComputerName $_server_to_act_on -Count 1 -Quiet ) {}

[bool](Invoke-Command -ComputerName "kgt-mi-hun868nb" -ScriptBlock {"hello from $env:COMPUTERNAME"} -ErrorAction SilentlyContinue)

# Passwort von lokalem User ändern
$Password = Read-Host -AsSecureString
$UserAccount = Get-LocalUser -Name "kirchner"
$UserAccount | Set-LocalUser -Password $Password

# Computernamen abfragen
$computerName = (Resolve-DnsName -Name $ipAddress -Type PTR).NameHost
$computerName = (Resolve-DnsName -Name 192.168.1.46 -Type PTR).NameHost


$AutoUpdates = New-Object -ComObject "Microsoft.Update.AutoUpdate"
$AutoUpdates.DetectNow()

############

# bitlocker

$BitlockerVolume = Get-BitLockerVolume -MountPoint C
$RecoveryKey = ($BitlockerVolume.KeyProtector).RecoveryPassword
Write-Output "The drive C has a recovery key $RecoveryKey."

# startup script of a specific domain user

# zuerst: 
Import-Module ActiveDirectory

Get-ADUser  -Identity <username> -Properties ScriptPath | Select-Object ScriptPath

# wenn auch der inhalt des scripts angezeigt werden soll
$scriptPath = (Get-ADUser  -Identity fel841 -Properties ScriptPath).ScriptPath
# Get-Content -Path $scriptPath
Get-Content -Path \\kgt-minden-dc\sysvol\stadthagen.kirchner-ingenieure.de\scripts\$scriptPath

# startup scripts of a group
Get-ADUser  -LDAPFilter "(objectClass=user)" -SearchScope Subtree -SearchBase "OU=KGT,DC=stadthagen,DC=kirchner-ingenieure,DC=de" -Properties ScriptPath | Select-Object Name, ScriptPath
Get-ADUser  -LDAPFilter "(objectClass=user)" -SearchScope Subtree -SearchBase "OU=KGT,DC=stadthagen,DC=kirchner-ingenieure,DC=de" -Properties ScriptPath | Select-Object Name, samaccountname, ScriptPath | Sort-Object Name | Export-CSV -Path "C:\inst\scriptpaths.csv" -NoTypeInformation

# set / change the script
Set-ADUser  -Identity "john.doe" -ScriptPath "C:\Scripts\newscript.bat"
Set-ADUser  -Identity "shelltest" -ScriptPath "KGT-User_MI_Zeichner.bat" -Credential $cred
Set-ADUser  -Identity "bog874" -ScriptPath "KGT-User_MI_Zeichner.bat" -Credential $cred

# change the password of a domain user
$newPassword = Read-Host "Enter new password" -AsSecureString
Set-ADAccountPassword -Identity "shelltest" -NewPassword $newPassword -Reset -Credential $cred

# list ad-usergroups
Get-ADGroup -Filter *
Get-ADGroup -Filter {Name -like "kgt*"}
Get-ADGroup -Filter {Name -like "kgt*"} | Select-Object Name

# list all computers of a domain
Get-ADComputer -Filter *
# Get-ADComputer -Filter {OperatingSystem -like "*Windows 10*"} -Properties Name, OperatingSystem, LastLogonDate

# search for computers by name
Get-ADComputer -Filter {Name -like "kgt*"}


Get-ADComputer -SearchBase "OU=Computers,OU=MyDepartment,DC=mydomain,DC=com" -Filter *
Get-ADComputer -SearchBase "OU=KGT-Rechner,OU=KGT,DC=stadthagen,DC=kirchner-ingenieure,DC=de" -Filter * # working

Get-ADComputer -Filter {OperatingSystem -like "*Windows 10*"} -Properties Name, OperatingSystem, LastLogonDate # working
Get-ADComputer -SearchBase "OU=KGT-Rechner,OU=KGT,DC=stadthagen,DC=kirchner-ingenieure,DC=de" -Filter {OperatingSystem -like "*Windows 10*"} -Properties Name, OperatingSystem, LastLogonDate 

# get the ad-ou's
Get-ADOrganizationalUnit -Filter {Name -like "kgt*"} # working
Get-ADOrganizationalUnit -Filter * # working
Get-ADOrganizationalUnit -Filter * | Select-Object Name # working


# deactivate the mouse
Disable-PnpDevice -InstanceId (Get-PnpDevice -PresentOnly | Where-Object { $_.Class -eq 'Mouse' }).InstanceId -Confirm:$false

# reactivate the mouse
Enable-PnpDevice -InstanceId (Get-PnpDevice -PresentOnly | Where-Object { $_.Class -eq 'Mouse' }).InstanceId -Confirm:$false
Enable-PnpDevice -InstanceId (Get-PnpDevice -PresentOnly | Where-Object { $_.Class -eq 'keyboard' }).InstanceId -Confirm:$false



