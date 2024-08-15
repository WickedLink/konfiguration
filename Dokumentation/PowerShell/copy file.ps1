# Datei auf Remote-Rechner kopieren
$FilePath = "C:\inst\EKU2invFHD.png"
# Define the folder path on the remote computer where to copy the install package
$DestFolderPath = "C:\inst"
# Read the list of remote computers from a file
$ComputerName = "kgt-mi-ps"

$Session = New-PSSession -ComputerName $ComputerName -Credential $cred
    
Invoke-Command -Session $Session -ScriptBlock {
    param($DestFolderPath)
    if (!(Test-Path $DestFolderPath)) {
        New-Item $DestFolderPath -ItemType Directory # | Out-Null
    }
} -ArgumentList $DestFolderPath

Copy-Item $FilePath -Destination $DestFolderPath -ToSession $Session
    
Remove-PSSession $Session


#######################################

# datei mit dialog kopieren und ziel manuell auswählen

# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Create an OpenFileDialog instance
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog

# Set initial properties
$OpenFileDialog.InitialDirectory = "C:\"
$OpenFileDialog.Filter = "All files (*.*)|*.*"
$OpenFileDialog.FilterIndex = 1
$OpenFileDialog.Multiselect = $false

# Show the dialog and get the selected file
$DialogResult = $OpenFileDialog.ShowDialog()

if ($DialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
    $FilePath = $OpenFileDialog.FileName
} else {
    Write-Host "File selection was cancelled." -ForegroundColor Red
    exit
}

# Read the list of remote computers from a file
$ComputerListFile = "c:\inst\computerlist.txt"
$Computers = Get-Content -Path $ComputerListFile

# Display the list of computers and ask the user to select one
Write-Host "Select a computer from the list:"
for ($i = 0; $i -lt $Computers.Count; $i++) {
    Write-Host "[$($i + 1)] $($Computers[$i])"
}

$Selection = Read-Host "Enter the number of the computer you want to select"
$SelectedComputer = $Computers[$Selection - 1]

# Define the folder path on the remote computer where to copy the install package
$DestFolderPath = "C:\inst"

$Session = New-PSSession -ComputerName $SelectedComputer -Credential $cred

Invoke-Command -Session $Session -ScriptBlock {
    param($DestFolderPath)
    if (!(Test-Path $DestFolderPath)) {
        New-Item $DestFolderPath -ItemType Directory # | Out-Null
    }
} -ArgumentList $DestFolderPath

Copy-Item $FilePath -Destination $DestFolderPath -ToSession $Session

Remove-PSSession $Session



########################################


# working
Invoke-Command -Session $session -ScriptBlock {
    param($username, $domain)
    $userSID = (New-Object System.Security.Principal.NTAccount($domain, $username)).Translate([System.Security.Principal.SecurityIdentifier])
    $userSID.Value
} -ArgumentList "fel841", "stadthagen"

$userSID = (New-Object System.Security.Principal.NTAccount("stadthagen", "fel841")).Translate([System.Security.Principal.SecurityIdentifier])
$path = "Registry::HKEY_USERS\$($userSID.Value)\Control Panel\Desktop"
Set-ItemProperty -Path $path -Name Wallpaper -Value "C:\inst\EKU2invFHD.png"

###


# Wallpaper per Registry ändern
$userSID = (New-Object System.Security.Principal.NTAccount("stadthagen", "fel841")).Translate([System.Security.Principal.SecurityIdentifier])
# eigentlich 
$WallpaperPath = "C:\inst\wallpaper_kgt_02.png"
$regpath = "Registry::HKEY_USERS\$($userSID)\Control Panel\Desktop" # working
# eigentlich $path = "Registry::HKEY_USERS\$($userSID.Value)\Control Panel\Desktop"
Set-ItemProperty -Path $RegPath -Name "Wallpaper" -Value $WallpaperPath
Set-ItemProperty -Path $RegPath -Name "WallpaperStyle" -Value "3"

# Wallpaperstyle müsste noch geändert werden
0 = Desktop Hintergrundbild wird zentriert dargestellt.
1 = Desktop Hintergrundbild wird nebeneinander dargestellt.
2 = Desktop Hintergrundbild wird gestreckt dargestellt.
3 = Desktop Hintergrundbild wird angepasst dargestellt. # kann man nehmen
4 = Desktop Hintergrundbild wird ausgefüllt dargestellt.
5 = Desktop Hintergrundbild wird übergreifend dargestellt.



#### ping a computer until it is reachable ####

$computerName = "kgt-mi-ps"
$reachable = $false

while (!$reachable) {
    $reachable = Test-Connection -ComputerName $computerName -Quiet
    if (!$reachable) {
        Write-Host "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Destination is not reachable. Waiting 5 seconds and trying again..."
        Start-Sleep -s 5
    }
}
Write-Host "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Destination is reachable!"

#### copy a file to another computer with openfiledialog

Add-Type -AssemblyName System.Windows.Forms

# Create an OpenFileDialog object
$FileDialog = New-Object System.Windows.Forms.OpenFileDialog
$FileDialog.InitialDirectory = "C:\"
$FileDialog.Filter = "Image files (*.png)|*.png"
$FileDialog.Title = "Select a file to copy"

# Show the file dialog and get the selected file
if ($FileDialog.ShowDialog() -eq "OK") {
    $FilePath = $FileDialog.FileName
} else {
    Write-Host "No file selected. Exiting."
    exit
}

# Define the folder path on the remote computer where to copy the install package
$DestFolderPath = "C:\inst"
# Read the list of remote computers from a file
$ComputerName = "kgt-mi-kue843"

$Session = New-PSSession -ComputerName $ComputerName -Credential $cred
    
Invoke-Command -Session $Session -ScriptBlock {
    param($DestFolderPath)
    if (!(Test-Path $DestFolderPath)) {
        New-Item $DestFolderPath -ItemType Directory # | Out-Null
    }
} -ArgumentList $DestFolderPath

Copy-Item $FilePath -Destination $DestFolderPath -ToSession $Session
    
Remove-PSSession $Session

####


Add-Type -AssemblyName PresentationCore, PresentationFramework, WindowsBase

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
         xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
         Title="My GUI" Height="200" Width="300"
         WindowStyle="SingleBorderWindow" Background="#FFCCCCCC">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <Label Grid.Row="0" Grid.Column="0" Margin="5" Foreground="Black">Enter your name:</Label>
        <TextBox x:Name="textBox" Grid.Row="1" Grid.Column="0" Margin="5" Width="250" Background="White" Foreground="Black" BorderBrush="Gray" />
        <Button x:Name="button" Grid.Row="2" Grid.Column="0" Margin="5" Width="75" Content="OK" Foreground="Black" Background="White" BorderBrush="Gray" />
        <Rectangle Grid.ColumnSpan="3" Grid.RowSpan="3" Fill="#FFCCCCCC" Opacity="0.5" />
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader([xml]$xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

$textBox = $window.FindName("textBox")
$button = $window.FindName("button")

$button.Add_Click({
    $window.Close()
})

$window.ShowDialog() | Out-Null

$name = $textBox.Text
Write-Host "Hello, $name!"

######################### kopieren mit fileopendialog

# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Create an OpenFileDialog instance
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog

# Set initial properties
$OpenFileDialog.InitialDirectory = "C:\"
$OpenFileDialog.Filter = "PNG files (*.png)|*.png|All files (*.*)|*.*"
$OpenFileDialog.FilterIndex = 1
$OpenFileDialog.Multiselect = $false

# Show the dialog and get the selected file
$DialogResult = $OpenFileDialog.ShowDialog()

if ($DialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
    $FilePath = $OpenFileDialog.FileName
} else {
    Write-Host "File selection was cancelled." -ForegroundColor Red
    exit
}

# Define the folder path on the remote computer where to copy the install package
$DestFolderPath = "C:\inst"
# Read the list of remote computers from a file
$ComputerName = "kgt-p-240601"

$Session = New-PSSession -ComputerName $ComputerName -Credential $cred

Invoke-Command -Session $Session -ScriptBlock {
    param($DestFolderPath)
    if (!(Test-Path $DestFolderPath)) {
        New-Item $DestFolderPath -ItemType Directory # | Out-Null
    }
} -ArgumentList $DestFolderPath

Copy-Item $FilePath -Destination $DestFolderPath -ToSession $Session

Remove-PSSession $Session

############################ networkscan with nmap

$nmapPath = "C:\Program Files (x86)\Nmap\nmap.exe"
$scanRange = "192.168.1.0/24"
$arguments = @($scanRange, "-sT")

# Run the Nmap scan
& $nmapPath $arguments

# Display the scan results
Write-Host "Scan Results:"
Get-Content "nmap_scan_results.txt" | ForEach-Object {
    if ($_ -match "Nmap scan report for (.*)") {
        Write-Host "  Host: $matches[1]" -ForegroundColor Green
    } elseif ($_ -match "PORT\s+STATE\s+SERVICE") {
        Write-Host "  Open Ports:" -ForegroundColor Green
    } elseif ($_ -match "\d+\/(tcp|udp)\s+(open|closed)\s+(.*)") {
        Write-Host "    - $matches[3] ($matches[1]/$matches[2])" -ForegroundColor Green
    }
}

################## network scan with nmap

$nmapPath = "C:\Program Files (x86)\Nmap\nmap.exe"
$scanRange = "192.168.1.0/24"
$arguments = @($scanRange, "-sT", "-v", "-oN", "C:\inst\nmap_scan_results.txt")

# Run the Nmap scan
& $nmapPath $arguments

# Display the scan results
Write-Host "Scan Results:"
Get-Content "C:\inst\nmap_scan_results.txt" | ForEach-Object {
    if ($_ -match "Nmap scan report for (.*)") {
        Write-Host "  Host: $matches[1]" -ForegroundColor Green
    } elseif ($_ -match "PORT\s+STATE\s+SERVICE") {
        Write-Host "  Open Ports:" -ForegroundColor Green
    } elseif ($_ -match "\d+\/(tcp|udp)\s+(open|closed)\s+(.*)") {
        Write-Host "    - $matches[3] ($matches[1]/$matches[2])" -ForegroundColor Green
    }
}

##################


Add-Type -AssemblyName System.Windows.Forms

$FileDialog = New-Object System.Windows.Forms.OpenFileDialog
$FileDialog.InitialDirectory = "C:\"
$FileDialog.Filter = "All files (*.*)|*.*"
$FileDialog.Title = "Select a file to copy"

if ($FileDialog.ShowDialog() -eq "OK") {
    $FilePath = $FileDialog.FileName
} else {
    Write-Host "No file selected. Exiting."
    exit
}

# Read the list of hosts from a file
$hostsFile = "C:\inst\computers.txt"  # Replace with the path to your hosts file
$hosts = Get-Content -Path $hostsFile

# Create a form to select the host
Add-Type -AssemblyName System.Windows.Forms
$form = New-Object System.Windows.Forms.Form
$form.Text = "Select a host"
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = "CenterScreen"

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(75,120)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = "OK"
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(150,120)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = "Cancel"
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = "Select a host:"
$form.Controls.Add($label)

$comboBox = New-Object System.Windows.Forms.ComboBox
$comboBox.Location = New-Object System.Drawing.Point(10,40)
$comboBox.Size = New-Object System.Drawing.Size(260,20)
$comboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$hosts | ForEach-Object {$comboBox.Items.Add($_) | Out-Null}
$form.Controls.Add($comboBox)

$form.Topmost = $true

$form.Add_Shown({$comboBox.Select()})
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $selectedHost = $comboBox.SelectedItem
} else {
    Write-Host "No host selected. Exiting."
    exit
}

# Copy the file to the selected host
$DestFolderPath = "C:\inst"
$cred = Get-Credential  # Replace with your credentials
$Session = New-PSSession -ComputerName $selectedHost -Credential $cred
Invoke-Command -Session $Session -ScriptBlock {
    param($DestFolderPath)
    if (!(Test-Path $DestFolderPath)) {
        New-Item $DestFolderPath -ItemType Directory
    }
} -ArgumentList $DestFolderPath
Copy-Item $FilePath -Destination $DestFolderPath -ToSession $Session
Remove-PSSession $Session


#############


Add-Type -AssemblyName System.Windows.Forms


$FileDialog = New-Object System.Windows.Forms.OpenFileDialog
$FileDialog.InitialDirectory = "C:\"
$FileDialog.Filter = "All files (*.*)|*.*"
$FileDialog.Title = "Select a file to copy"


if ($FileDialog.ShowDialog() -eq "OK") {
    $FilePath = $FileDialog.FileName
} else {
    Write-Host "No file selected. Exiting."
    exit
}

# Read destination hosts from a file
$hostsFile = "C:\inst\computers.txt"
$hosts = Get-Content $hostsFile

# Display the list of hosts and ask the user to choose one
Write-Host "Choose a destination host:"
for ($i = 0; $i -lt $hosts.Count; $i++) {
    Write-Host "  $($i + 1): $($hosts[$i])"
}

$choice = Read-Host "Enter the number of the host"
$ComputerName = $hosts[$choice - 1]

# Establish a remote PowerShell session
$Session = New-PSSession -ComputerName $ComputerName -Credential $cred

# Define the folder path on the remote computer where to copy the install package
$DestFolderPath = "C:\inst"

Invoke-Command -Session $Session -ScriptBlock {
    param($DestFolderPath)
    if (!(Test-Path $DestFolderPath)) {
        New-Item $DestFolderPath -ItemType Directory # | Out-Null
    }
} -ArgumentList $DestFolderPath

Copy-Item $FilePath -Destination $DestFolderPath -ToSession $Session
    
Remove-PSSession $Session

########################## get fileversion

(Get-Item -Path "C:\Program Files\PDF24\pdf24.exe").VersionInfo.fileversion
(Get-Item -Path "C:\Program Files\tracker software\pdf editor\pdfxedit.exe").VersionInfo.fileversion

##########################

# $sourceMSI = "C:\inst\EditorV10.x64.msi"


Add-Type -AssemblyName System.Windows.Forms

# Function to open a file dialog and select an MSI file
function Select-MSIFile {
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "MSI files (*.msi)|*.msi"
    $openFileDialog.Title = "Select the MSI file to deploy"
    # $openFileDialog.InitialDirectory = [Environment]::GetFolderPath("Desktop")
    $openFileDialog.InitialDirectory = "C:\"
    
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $openFileDialog.FileName
    } else {
        Write-Host "No file selected. Exiting script."
        exit
    }
}

# Use the function to get the source MSI file
$sourceMSI = Select-MSIFile

# Define other variables
$destinationPath = "C:\inst"
$remoteComputer = "kgt-mi-ps"
$msiFileName = [System.IO.Path]::GetFileName($sourceMSI)

# Prompt for credentials
$credential = Get-Credential

# Create a session to the remote computer with the provided credentials
$session = New-PSSession -ComputerName $remoteComputer -Credential $credential

# Create the destination folder on the remote computer if it doesn't exist
Invoke-Command -Session $session -ScriptBlock {
    param ($destinationPath)
    if (-Not (Test-Path -Path $destinationPath)) {
        New-Item -Path $destinationPath -ItemType Directory
    }
} -ArgumentList $destinationPath

# Copy the MSI file to the destination folder on the remote computer
Copy-Item -Path $sourceMSI -Destination $destinationPath -ToSession $session

# Install the MSI file silently on the remote computer
Invoke-Command -Session $session -ScriptBlock {
    param ($destinationPath, $msiFileName)
    $msiFilePath = Join-Path -Path $destinationPath -ChildPath $msiFileName
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $msiFilePath /quiet /norestart" -Wait
} -ArgumentList $destinationPath, $msiFileName


    # # Install the Software silently on the remote computer
    # Invoke-Command -Session $Session -ScriptBlock {
    #     param($FilePath)
    #     Start-Process -FilePath $FilePath -ArgumentList "/S" -Wait
    # } -ArgumentList $FilePath


# Remove the session
Remove-PSSession -Session $session


#########


Install-Module -Name PSWindowsUpdate -Force -SkipPublisherCheck

Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
Import-Module PSWindowsUpdate
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Restricted


################# task für windows update erstellen


$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-ExecutionPolicy Bypass -File "C:\inst\InstallUpdates.ps1"'
$trigger = New-ScheduledTaskTrigger -At 3am -Daily
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName "Install Windows Updates" -Action $action -Trigger $trigger -Principal $principal -Settings $settings

#################

$PSVersionTable

# alle tasks anzeigen
Get-ScheduledTask

# alle tasks mit bestimmten werten anzeigen
Get-ScheduledTask | Select-Object TaskName, TaskPath, State, NextRunTime, Author

# alle tasks anzeigen, die das wort "update" enthalten
Get-ScheduledTask | Where-Object {$_.TaskName -like "*update*"}

# eigenschaften eines bestimmten tasks anzeigen
Get-ScheduledTask -TaskName "install windows updates" | fl *

# trigger eines tasks anzeigen
(Get-ScheduledTask -TaskName "install windows updates").Triggers

# taks manuell starten
Start-ScheduledTask -TaskName "install windows updates"

# check if windowsupate is running
Get-Process -Name wuauclt | Select-Object Id, ProcessName, StartTime

# check if windowsupate is running
Get-Service -Name wuauserv | Select-Object Status

# disable scheduled task
Disable-ScheduledTask -TaskName $taskName -ComputerName $computerName
Disable-ScheduledTask -TaskName $taskName 
Disable-ScheduledTask -TaskName "install windows updates"

# enable scheduled task
Enable-ScheduledTask -TaskName $taskName -ComputerName $computerName
Enable-ScheduledTask -TaskName "install windows updates"

# completely remove a scheduled task
Unregister-ScheduledTask -TaskName $taskName -ComputerName $computerName

# smbshares anzeigen
Get-SmbShare

New-SmbShare -Name "inst" -Path "C:\inst" -FullAccess "Everyone" # not working
New-SmbShare -Name "inst" -Path "C:\inst" -FullAccess "S-1-1-0" # not working
New-SmbShare -Name "inst" -Path "C:\inst" -FullAccess "stadthagen\fel841"
New-SmbShare -Name "inst" -Path "C:\inst" -FullAccess "Everyone" -Description "install files" -EncryptData $true

Remove-SmbShare -Name "inst" -Force

robocopy <local_file_path> \\remote_computer_name\c$\remote_file_path /mov /z
robocopy c:\inst\ '\\kgt-mi-dem804\c$\inst' A1-INSTALLATIONSDATEIEN-TRIMBLE_NOVA_18-0.zip /z
robocopy c:\inst\ '\\kgt-mi-dem804\inst' A1-INSTALLATIONSDATEIEN-TRIMBLE_NOVA_18-0.zip /z

#####################

# Define the remote computer name and the file to copy
$remoteComputer = "kgt-mi-dem804"
$localFilePath = "C:\Path\To\Local\File.txt"
$remoteShareName = "inst"

# Create a new SMB share on the remote computer
Invoke-Command -ComputerName $remoteComputer -ScriptBlock {
    New-SmbShare -Name $using:remoteShareName -Path "C:\inst" -FullAccess "stadthagen\fel841"
} -Credential $cred

# Copy the file to the remote share
Copy-Item -Path $localFilePath -Destination "\\$remoteComputer\$remoteShareName"

# Remove the SMB share on the remote computer
Invoke-Command -ComputerName $remoteComputer -ScriptBlock {
    Remove-SmbShare -Name $using:remoteShareName -Force
} -Credential $cred

#########################


### create a local user
New-LocalUser -Name <Username> -Password <Password> -FullName <FullName> -Description <Description>
New-LocalUser -Name JohnDoe -Password (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force) -FullName "John Doe" -Description "Local user account"
New-LocalUser -Name kirchner -Password (ConvertTo-SecureString "16+kgt-mi-ps-09" -AsPlainText -Force)


This will create a new local user account on the remote computer with the username JohnDoe, password P@ssw0rd, full name John Doe, and description Local user account.
Note that you need to use the ConvertTo-SecureString cmdlet to convert the password to a secure string, as required by the New-LocalUser cmdlet.

This would add the JohnDoe user to the Administrators group.
Add-LocalGroupMember -Group "Administrators" -Member "JohnDoe"
Add-LocalGroupMember -Group "Administratoren" -Member "kirchner" # Gruppen haben dann natuerlich deutsche Namen

Add-LocalGroupMember -Group "Remotedesktopbenutzer" -Member "stadthagen\fel841" # working
Add-LocalGroupMember -Group "Administratoren" -Member "stadthagen\fel841" # Gruppen haben dann natuerlich deutsche Namen
Add-LocalGroupMember -Group "Remotedesktopbenutzer" -Member "stadthagen\fel841" # Gruppen haben dann natuerlich deutsche Namen

# lokale User anzeigen
Get-LocalUser

# To get a list of all user accounts, including their names, full names, and descriptions:
Get-LocalUser | Select-Object Name, FullName, Description

# To get a list of all enabled user accounts:
Get-LocalUser | Where-Object {$_.Enabled -eq $true}

# To get a list of all user accounts that are members of a specific group (e.g., "Administrators"):
Get-LocalUser | Where-Object {$_.PrincipalSource -eq "Local" -and $_.GroupList -contains "Administrators"}

# To get a list of all user accounts with their corresponding SID (Security Identifier):
Get-LocalUser | Select-Object Name, SID

# This will retrieve a list of all local groups on the remote computer.
Get-LocalGroup

# To get a list of all group names:
Get-LocalGroup | Select-Object Name

# To get a list of all groups that a specific user is a member of:
Get-LocalGroup | Where-Object {$_.Name -in (Get-LocalUser -Name <Username>).GroupList}

########################################

# Öffnen Sie eine Remote PowerShell-Sitzung
# Enter-PSSession -ComputerName "RemoteComputerName" -Credential (Get-Credential)

# Schritt 1: Remote Desktop in der Registrierung aktivieren
Invoke-Command -ScriptBlock {
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
}

# Schritt 2: Remote Desktop-Dienst starten und auf Automatisch setzen
Invoke-Command -ScriptBlock {
    Get-Service -Name "TermService" | Set-Service -StartupType Automatic
    Start-Service -Name "TermService"
}

# Schritt 3: Firewall-Regel hinzufügen, um RDP zuzulassen
Invoke-Command -ScriptBlock {
    Enable-NetFirewallRule -DisplayGroup "Remotedesktop"
}

# Bestätigen Sie, dass die Änderungen erfolgreich waren
Invoke-Command -ScriptBlock {
    $rdpStatus = Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections"
    $firewallRule = Get-NetFirewallRule -DisplayGroup "Remotedesktop" | Get-NetFirewallRule | Where-Object { $_.Enabled -eq 'True' }

    if ($rdpStatus.fDenyTSConnections -eq 0 -and $firewallRule) {
        Write-Output "Remote Desktop ist aktiviert und die Firewall-Regeln sind konfiguriert."
    } else {
        Write-Output "Es gab ein Problem bei der Konfiguration von Remote Desktop oder der Firewall-Regeln."
    }
}

# Beenden Sie die Remote PowerShell-Sitzung
# Exit-PSSession



########################################

$user = [Security.Principal.WindowsIdentity]::GetCurrent()

Get-LocalGroupMember -Group "Administratoren" # working

Remove-LocalGroupMember -Group "Administratoren" -Member "stadthagen\domänen-benutzer"

### rdp stuff
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Type DWORD -Value 0 -Force
Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' | Select-Object -ExpandProperty fDenyTSConnections

Get-Module -ListAvailable PSWindowsUpdate


Import-Module PSWindowsUpdate

Get-WindowsUpdate
Get-WUList

Get-WindowsUpdate -Category "CriticalUpdates", "SecurityUpdates", "DefinitionUpdates", "FeaturePacks", "Upgrades"
Get-WindowsUpdate -Category "security"

# funktionieren:
Get-WindowsUpdate -Category "security" -MicrosoftUpdate
Get-WindowsUpdate -Category "driver" -MicrosoftUpdate  
Get-WindowsUpdate -Category "update" -MicrosoftUpdate # sieht gut aus

# from claude
"Security Updates"
"Critical Updates"
"Definition Updates"
"Updates"
"Feature Packs"
"Service Packs"
"Tools"
"Drivers"

Get-WUHistory

Get-WUSettings

Get-WindowsUpdate -Install -KBArticleID kb2267602
Get-WindowsUpdate -Install -KBArticleID <KB_Article_ID>
Install-WindowsUpdate -KBArticleID $updateToInstall.KBArticleID -AcceptAll -AutoReboot
Install-WindowsUpdate -KBArticleID KBArticleID 

# lest event-logs containing windows update
Get-EventLog -LogName System -Source Microsoft-Windows-WindowsUpdateClient -Newest 40

############################

# alle installierten programme abfragen und in die zwischenablage kopieren
Get-Package -ProviderName Programs,msi | Select-Object Name, Version | Sort Name | Clip
Get-Package -ProviderName Programs,msi | Select-Object Name, Version | Sort Name

############################

Get-Process -Name "processname" | Select-Object -Property Name, Id, CPU
Get-Process -Name "explorer" | Select-Object -Property Name, Id, CPU
Get-Process -Name "system" | Select-Object -Property Name, Id, CPU



#############################

# list all autostart programs
Get-CimInstance Win32_StartupCommand | Select-Object Name, command, Location, User | Format-List 


############################ copy file to remote pc per smb share


# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Create an OpenFileDialog instance
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog

# Set initial properties
$OpenFileDialog.InitialDirectory = "C:\"
$OpenFileDialog.Filter = "All files (*.*)|*.*"
$OpenFileDialog.FilterIndex = 1
$OpenFileDialog.Multiselect = $false

# Show the dialog and get the selected file
$DialogResult = $OpenFileDialog.ShowDialog()

if ($DialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
    $FilePath = $OpenFileDialog.FileName
} else {
    Write-Host "File selection was cancelled." -ForegroundColor Red
    exit
}

# Read the list of remote computers from a file
$ComputerListFile = "c:\inst\computerlist.txt"
$Computers = Get-Content -Path $ComputerListFile

# Display the list of computers and ask the user to select one
Write-Host "Select a computer from the list:"
for ($i = 0; $i -lt $Computers.Count; $i++) {
    Write-Host "[$($i + 1)] $($Computers[$i])"
}

$Selection = Read-Host "Enter the number of the computer you want to select"
$SelectedComputer = $Computers[$Selection - 1]

# Define the folder path on the remote computer where to copy the install package
# $DestFolderPath = "\\$SelectedComputer\c$\inst"
$DestFolderPath = "c:\inst"

# Create a network share for the destination folder
$ShareName = "inst_share"
Invoke-Command -ComputerName $SelectedComputer -ScriptBlock {
    param($DestFolderPath, $ShareName)
    New-SmbShare -Name $ShareName -Path $DestFolderPath -FullAccess "Jeder"
} -ArgumentList $DestFolderPath, $ShareName -Credential $cred

# Copy the file to the network share using Robocopy
$SharePath = "\\$SelectedComputer\$ShareName"
# Robocopy /copyall $FilePath $SharePath
Robocopy $(Split-Path $FilePath) $SharePath $(Split-Path $FilePath -Leaf) /z

# Remove the network share
Invoke-Command -ComputerName $SelectedComputer -ScriptBlock {
    param($ShareName)
    Remove-SmbShare -Name $ShareName -Force
} -ArgumentList $ShareName -Credential $cred


######################################

New-SmbShare -Name "inst" -Path "C:\inst" -FullAccess "stadthagen\fel841"
New-SmbShare -Name "inst" -Path $DestFolderPath -FullAccess "stadthagen\fel841"
Remove-SmbShare -Name "inst" -Force
$DestFolderPath = "\\kgt-mi-ps\c$\inst"
$DestFolderPath = "c:\inst"
robocopy c:\inst\ '\\kgt-mi-dem804\inst' A1-INSTALLATIONSDATEIEN-TRIMBLE_NOVA_18-0.zip /z
Robocopy /copyall /mov $(Split-Path $FilePath) $SharePath $(Split-Path $FilePath -Leaf)


##### uninstall software
# Get a list of installed packages
Get-Package
$packages = Get-Package -Name <SoftwareName>
$packages = Get-Package -Name "*pdf*"
$packages = Get-Package -Name "*pdf24*"
$packages = Get-Package -Name "*7-zip*"
$packages = Get-Package -Name "*nova 16*"
$packages = Get-Package -Name "*else*"
$packages

# Uninstall the package
$packages | Uninstall-Package -Confirm:$false

#############

# download a file
Invoke-WebRequest -Uri "https://7-zip.org/a/7z2407-x64.msi" -OutFile ".\7z2407-x64.msi"
Invoke-WebRequest -Uri "https://jabraxpressonlineprdstor.blob.core.windows.net/jdo/JabraDirectSetup.exe" -OutFile ".\JabraDirectSetup.exe"
Invoke-WebRequest -Uri "https://simaris-toolbox.siemens.cloud/download/suite/simaris-suite-installer.exe" -OutFile ".\simaris-suite-installer.exe"

# delete a file
Remove-Item -Path "example.txt" -Force

# delete a folder
Remove-Item -Path "C:\Path\To\MyFolder" -Recurse -Force

# retrieve path variable
$env:PATH
$env:PATH -split ';'

# test if .NET framework 4.6.2 is installed
Test-Path -Path "C:\Windows\Microsoft.NET\Framework\v4.0.30319"

# test if ms sql server compact edition 3.5 is installed
Test-Path -Path "C:\Program Files\Microsoft SQL Server Compact Edition\v3.5"



###################### copy file to remote pc per smb share and install if it's an msi

# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Create an OpenFileDialog instance
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog

# Set initial properties
$OpenFileDialog.InitialDirectory = "C:\"
$OpenFileDialog.Filter = "All files (*.*)|*.*"
$OpenFileDialog.FilterIndex = 1
$OpenFileDialog.Multiselect = $false

# Show the dialog and get the selected file
$DialogResult = $OpenFileDialog.ShowDialog()

if ($DialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
    $FilePath = $OpenFileDialog.FileName
} else {
    Write-Host "File selection was cancelled." -ForegroundColor Red
    exit
}

# Read the list of remote computers from a file
$ComputerListFile = "c:\inst\computerlist.txt"
$Computers = Get-Content -Path $ComputerListFile

# Display the list of computers and ask the user to select one
Write-Host "Select a computer from the list:"
for ($i = 0; $i -lt $Computers.Count; $i++) {
    Write-Host "[$($i + 1)] $($Computers[$i])"
}

$Selection = Read-Host "Enter the number of the computer you want to select"
$SelectedComputer = $Computers[$Selection - 1]

# Define the folder path on the remote computer where to copy the install package
$DestFolderPath = "c:\inst"

# Create a network share for the destination folder
$ShareName = "inst_share"
Invoke-Command -ComputerName $SelectedComputer -ScriptBlock {
    param($DestFolderPath, $ShareName)
    New-SmbShare -Name $ShareName -Path $DestFolderPath -FullAccess "Jeder"
} -ArgumentList $DestFolderPath, $ShareName -Credential $cred

# Copy the file to the network share using Robocopy
$SharePath = "\\$SelectedComputer\$ShareName"
Robocopy $(Split-Path $FilePath) $SharePath $(Split-Path $FilePath -Leaf) /z

# Check if the copied file is an MSI file
# $CopiedFilePath = Join-Path $SharePath $(Split-Path $FilePath -Leaf)
$CopiedFilePath = Join-Path $DestFolderPath $(Split-Path $FilePath -Leaf)
if ($CopiedFilePath -like "*.msi") {
    Write-Host "The copied file is an MSI file."
    $InstallRemotely = Read-Host "Do you want to install it remotely? (yes/no)"
    if ($InstallRemotely -eq "yes") {
        Write-Host "Installing the MSI file on $SelectedComputer..."
        Invoke-Command -ComputerName $SelectedComputer -ScriptBlock {
            param($CopiedFilePath)
            # msiexec.exe /i $CopiedFilePath /quiet /norestart # working
            # msiexec.exe /x $CopiedFilePath /quiet /norestart # not tested

            $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $CopiedFilePath /quiet" -Wait -PassThru
            if ($process.ExitCode -ne 0) {
                Write-Host "Installation failed with exit code $($process.ExitCode)" -ForegroundColor Red
            } else {
                Write-Host "Installation complete." -ForegroundColor Green
            }

        } -ArgumentList $CopiedFilePath -Credential $cred
        # Write-Host "Installation complete."
    } else {
        Write-Host "Not installing the MSI file remotely."
    }
} else {
    Write-Host "The copied file is not an MSI file."
}

# Remove the network share
Invoke-Command -ComputerName $SelectedComputer -ScriptBlock {
    param($ShareName)
    Remove-SmbShare -Name $ShareName -Force
} -ArgumentList $ShareName -Credential $cred

############## funktioniert bis hier


############### das gleiche um zip dateien erweitert




# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Create an OpenFileDialog instance
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog

# Set initial properties
$OpenFileDialog.InitialDirectory = "C:\"
$OpenFileDialog.Filter = "All files (*.*)|*.*"
$OpenFileDialog.FilterIndex = 1
$OpenFileDialog.Multiselect = $false

# Show the dialog and get the selected file
$DialogResult = $OpenFileDialog.ShowDialog()

if ($DialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
    $FilePath = $OpenFileDialog.FileName
} else {
    Write-Host "File selection was cancelled." -ForegroundColor Red
    exit
}

# Read the list of remote computers from a file
$ComputerListFile = "c:\inst\computerlist.txt"
$Computers = Get-Content -Path $ComputerListFile

if ($Computers.Count -eq 0) {
    Write-Host "No computers found in the list." -ForegroundColor Red
    exit
} elseif ($Computers.Count -eq 1) {
    $SelectedComputer = $Computers[0]
    Write-Host "Only one computer in the list. Automatically selected: $SelectedComputer"
} else {
    # Display the list of computers and ask the user to select one
    Write-Host "Select a computer from the list:"
    for ($i = 0; $i -lt $Computers.Count; $i++) {
        Write-Host "[$($i + 1)] $($Computers[$i])"
    }

    do {
        $Selection = Read-Host "Enter the number of the computer you want to select"
        
        # Check if the input is a valid number and within range
        $ValidSelection = $Selection -as [int]
        if ($ValidSelection -and $ValidSelection -gt 0 -and $ValidSelection -le $Computers.Count) {
            $SelectedComputer = $Computers[$ValidSelection - 1]  # Adjust for 0-based index
            break
        } else {
            Write-Host "Invalid selection. Please enter a valid number." -ForegroundColor Red
        }
    } while ($true)
}

# Define the folder path on the remote computer where to copy the install package
$DestFolderPath = "c:\inst"


Invoke-Command -ComputerName $SelectedComputer -ScriptBlock {
    param($DestFolderPath)
    if (!(Test-Path $DestFolderPath)) {
        New-Item $DestFolderPath -ItemType Directory # | Out-Null
    }
} -ArgumentList $DestFolderPath -Credential $cred


# Create a network share for the destination folder
$ShareName = "inst_share"
Invoke-Command -ComputerName $SelectedComputer -ScriptBlock {
    param($DestFolderPath, $ShareName)
    New-SmbShare -Name $ShareName -Path $DestFolderPath -FullAccess "Jeder"
} -ArgumentList $DestFolderPath, $ShareName -Credential $cred

# Copy the file to the network share using Robocopy
$SharePath = "\\$SelectedComputer\$ShareName"
Robocopy $(Split-Path $FilePath) $SharePath $(Split-Path $FilePath -Leaf) /z

# Check if the copied file is an MSI file or a ZIP archive
$CopiedFilePath = Join-Path $DestFolderPath $(Split-Path $FilePath -Leaf)
if ($CopiedFilePath -like "*.msi") {
    Write-Host "The copied file is an MSI file."
    $InstallRemotely = Read-Host "Do you want to install it remotely? (yes/no)"
    if ($InstallRemotely -eq "yes") {
        Write-Host "Installing the MSI file on $SelectedComputer..."
        Invoke-Command -ComputerName $SelectedComputer -ScriptBlock {
            param($CopiedFilePath)
            $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $CopiedFilePath /quiet /norestart" -Wait -PassThru
            if ($process.ExitCode -ne 0) {
                Write-Host "Installation failed with exit code $($process.ExitCode)" -ForegroundColor Red
            } else {
                Write-Host "Installation complete." -ForegroundColor Green
            }
        } -ArgumentList $CopiedFilePath -Credential $cred
    } else {
        Write-Host "Not installing the MSI file remotely."
    }
} elseif ($CopiedFilePath -like "*.zip") {
    Write-Host "The copied file is a ZIP archive."
    $UnzipRemotely = Read-Host "Do you want to unzip it remotely? (yes/no)"
    if ($UnzipRemotely -eq "yes") {
        # Determine the folder name based on the ZIP file name
        $ZipFolderName = [System.IO.Path]::GetFileNameWithoutExtension($CopiedFilePath)
        $UnzipDestPath = Join-Path $DestFolderPath $ZipFolderName

        Write-Host "Unzipping the ZIP archive on $SelectedComputer to folder: $UnzipDestPath"
        Invoke-Command -ComputerName $SelectedComputer -ScriptBlock {
            param($CopiedFilePath, $UnzipDestPath)
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::ExtractToDirectory($CopiedFilePath, $UnzipDestPath)
            Write-Host "Unzipping complete." -ForegroundColor Green
        } -ArgumentList $CopiedFilePath, $UnzipDestPath -Credential $cred
    } else {
        Write-Host "Not unzipping the ZIP archive remotely."
    }
} else {
    Write-Host "The copied file is not an MSI file or a ZIP archive."
}

# Remove the network share
Invoke-Command -ComputerName $SelectedComputer -ScriptBlock {
    param($ShareName)
    Remove-SmbShare -Name $ShareName -Force
} -ArgumentList $ShareName -Credential $cred



###########################


###########################

# File manager script

# Set the current directory
$currDir = Get-Location

# Function to display the directory contents
function Show-Dir {
  param ($dir)
  Write-Host "Directory: $dir" -ForegroundColor Green
  Get-ChildItem $dir | ForEach-Object {
    if ($_.PSIsContainer) {
      Write-Host "  $_" -ForegroundColor Cyan
    } else {
      Write-Host "  $_" -ForegroundColor White
    }
  }
}

# Function to navigate to a directory
function Nav-Dir {
  param ($dir)
  Set-Location $dir
  Show-Dir $dir
}

# Main loop
while ($true) {
  Show-Dir $currDir
  $input = Read-Host "Enter a directory or command (q to quit)"
  if ($input -eq "q") { break }
  if (Test-Path $input) {
    Nav-Dir $input
  } else {
    Write-Host "Invalid directory" -ForegroundColor Red
  }
}


#####################
Add-WindowsCapability -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 -Online

######################


$processName = "nextcloud"
$process = Get-Process -Name $processName
$filePath = $process.MainModule.FileName

$fileVersionInfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($filePath)
$versionNumber = $fileVersionInfo.FileVersion

Write-Host "Version number of " + $processName + ": " + $versionNumber

###########################
