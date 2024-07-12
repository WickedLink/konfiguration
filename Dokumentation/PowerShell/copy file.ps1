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


$username = "fel841"  # Replace with the actual username
$user = Get-WmiObject -Query "select * from Win32_UserAccount where Name='$username'"
$path = "Registry::HKEY_USERS\$($user.SID)\Control Panel\Desktop"
Set-ItemProperty -Path $path -Name Wallpaper -Value "C:\inst\EKU2invFHD.png"

########################################

Get-Module -Name ActiveDirectory -ListAvailable
Get-WindowsFeature -Name RSAT-AD-PowerShell #works only on servers

Import-Module ActiveDirectory -ErrorAction SilentlyContinue
if (!$?) {
    Write-Host "Active Directory PowerShell module is not installed"
} else {
    Write-Host "Active Directory PowerShell module is installed"
}

Add-WindowsCapability -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 -Online

$session = New-PSSession -ComputerName kgt-mi-ps -Credential $cred
Invoke-Command -Session $session -ScriptBlock { Add-WindowsCapability -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 -Online }

Invoke-Command -Session $session -ScriptBlock { Start-Process -Wait -FilePath powershell -ArgumentList @("Add-WindowsCapability -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 -Online") -Verb RunAs }

Get-WindowsCapability -Name RSAT* -Online # working

Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online
Add-WindowsCapability -name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 -Online

Enable-WSManCredSSP -Role Client -DelegateComputer "kgt-mi-ps"
Enable-WSManCredSSP -Role Server

$cred = Get-Credential
Enter-PSSession -ComputerName "remote_computer_name" -Credential $cred -Authentication CredSSP

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
$UserSID = (Get-ADUser -Identity 'username').SID.Value
$RegPath = "HKU:\$UserSID\Control Panel\Desktop"
$WallpaperPath = "C:\inst\EKU2invFHD.png"

Invoke-Command -ComputerName "RemotePCName" -ScriptBlock {
    param($RegPath, $WallpaperPath)
    Set-ItemProperty -Path $RegPath -Name "Wallpaper" -Value $WallpaperPath
} -ArgumentList $RegPath, $WallpaperPath


$userSID = (New-Object System.Security.Principal.NTAccount("stadthagen", "fel841")).Translate([System.Security.Principal.SecurityIdentifier])
$WallpaperPath = "C:\inst\EKU2invFHD.png"
$regpath = "Registry::HKEY_USERS\$($userSID)\Control Panel\Desktop" # working

# Wallpaperstyle müsste noch geändert werden

###




########################################





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

