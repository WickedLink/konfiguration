Invoke-Command -ComputerName kgt-mi-hun868nb -Credential $cred -ScriptBlock {
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-WindowStyle Hidden -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show(''Your long message'', ''Title'')}"'
    $principal = New-ScheduledTaskPrincipal -UserId (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty UserName)
    $task = New-ScheduledTask -Action $action -Principal $principal
    Register-ScheduledTask -TaskName "ShowMessage" -InputObject $task
    Start-ScheduledTask -TaskName "ShowMessage"
    Start-Sleep -Seconds 5
    Unregister-ScheduledTask -TaskName "ShowMessage" -Confirm:$false
}



Invoke-Command -ComputerName kgt-mi-hun868nb -Credential $cred -ScriptBlock {
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-WindowStyle Hidden -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show(''$msg'' , ''Message from bul871'',0,[System.Windows.Forms.MessageBoxIcon]::stop)}"'
    $principal = New-ScheduledTaskPrincipal -UserId (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty UserName)
    $task = New-ScheduledTask -Action $action -Principal $principal
    Register-ScheduledTask -TaskName "ShowMessage" -InputObject $task
    Start-ScheduledTask -TaskName "ShowMessage"
    Start-Sleep -Seconds 5
    Unregister-ScheduledTask -TaskName "ShowMessage" -Confirm:$false
}

Invoke-Command -ComputerName kgt-mi-hun868nb -Credential $cred -ScriptBlock {
    Disable-PnpDevice -InstanceId (Get-PnpDevice -PresentOnly | Where-Object { $_.Class -eq 'Mouse' }).InstanceId -Confirm:$false
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-WindowStyle Hidden -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show(''Nix mehr Maus...'' , ''Message from bul871'',0)}"'
    $principal = New-ScheduledTaskPrincipal -UserId (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty UserName)
    $task = New-ScheduledTask -Action $action -Principal $principal
    Register-ScheduledTask -TaskName "ShowMessage" -InputObject $task
    Start-ScheduledTask -TaskName "ShowMessage"
    Start-Sleep -Seconds 5
    Unregister-ScheduledTask -TaskName "ShowMessage" -Confirm:$false
}



Invoke-Command -ComputerName kgt-mi-hun868nb -Credential $cred -ScriptBlock {
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-WindowStyle Hidden -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show(
    ''Zeile1
Zeile2
Zeile3'', ''Title'')}"'
    $principal = New-ScheduledTaskPrincipal -UserId (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty UserName)
    $task = New-ScheduledTask -Action $action -Principal $principal
    Register-ScheduledTask -TaskName "ShowMessage" -InputObject $task
    Start-ScheduledTask -TaskName "ShowMessage"
    Start-Sleep -Seconds 5
    Unregister-ScheduledTask -TaskName "ShowMessage" -Confirm:$false
}




# create a task to lock the computer
Invoke-Command -ComputerName kgt-mi-hun868nb -Credential $cred -ScriptBlock {
    $action = New-ScheduledTaskAction -Execute 'rundll32.exe' -Argument 'user32.dll,LockWorkStation'
    $principal = New-ScheduledTaskPrincipal -UserId (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty UserName)
    $task = New-ScheduledTask -Action $action -Principal $principal
    Register-ScheduledTask -TaskName "LockComputer" -InputObject $task
    Start-ScheduledTask -TaskName "LockComputer"
    Start-Sleep -Seconds 5
    Unregister-ScheduledTask -TaskName "LockComputer" -Confirm:$false
}


Invoke-Command -ComputerName kgt-mi-hun868nb -Credential $cred -ScriptBlock {
    # Path to the new lock screen image (must be .jpg)
    $newLockScreenImagePath = "C:\inst\a1.jpg"

    # Copy the image to Windows lock screen folder
    $lockScreenFolder = "$env:WINDIR\Web\Screen"
    Copy-Item -Path $newLockScreenImagePath -Destination "$lockScreenFolder\LockScreen.jpg" -Force

    # Registry key to set the lock screen image
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
    
    # Ensure the registry path exists
    if (!(Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }

    # Set the lock screen image
    Set-ItemProperty -Path $registryPath -Name "LockScreenImage" -Value "$lockScreenFolder\LockScreen.jpg"
}


Invoke-Command -ComputerName kgt-mi-hun868nb -Credential $cred -ScriptBlock {
    $newLockScreenImagePath = "C:\inst\a1.jpg"
    $userProfilePath = "C:\Users\fel841\AppData\Local\Microsoft\Windows\Background Images"
    
    # Ensure the directory exists
    New-Item -ItemType Directory -Path $userProfilePath -Force

    # Copy the image
    Copy-Item -Path $newLockScreenImagePath -Destination "$userProfilePath\LockScreen.jpg" -Force
}


Invoke-Command -ComputerName kgt-mi-hun868nb -Credential $cred -ScriptBlock {
    $username = "fel841"
    $newLockScreenImagePath = "C:\inst\a1.jpg"

    # Impersonate the user
    $userProfile = Get-CimInstance Win32_UserProfile | Where-Object { $_.LocalPath -like "*$username*" }
    
    # Switch to the user's context
    $userSid = $userProfile.SID
    $userRegPath = "HKEY_USERS\$userSid\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"

    # Set lock screen image using the correct registry path
    New-ItemProperty -Path "Registry::$userRegPath" -Name "LockScreenImagePath" -Value $newLockScreenImagePath -PropertyType String -Force
    New-ItemProperty -Path "Registry::$userRegPath" -Name "LockScreenImageUrl" -Value $newLockScreenImagePath -PropertyType String -Force
}


# script seems good, but does not show the image
Invoke-Command -ComputerName kgt-mi-hun868nb -Credential $cred -ScriptBlock {
    $username = "fel841"
    $newLockScreenImagePath = "C:\inst\a1.jpg"

    # Impersonate the user
    $userProfile = Get-CimInstance Win32_UserProfile | Where-Object { $_.LocalPath -like "*$username*" }
    
    # Switch to the user's context
    $userSid = $userProfile.SID
    $userRegPath = "HKEY_USERS\$userSid\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"

    # Convert to PowerShell registry path
    $psRegistryPath = "Registry::$userRegPath"

    # Check if registry path exists, create if not
    if (!(Test-Path -Path $psRegistryPath)) {
        try {
            New-Item -Path $psRegistryPath -Force | Out-Null
            Write-Host "Registry path created successfully."
        }
        catch {
            Write-Error "Failed to create registry path: $_"
            return
        }
    }

    # Set lock screen image
    try {
        New-ItemProperty -Path $psRegistryPath -Name "LockScreenImagePath" -Value $newLockScreenImagePath -PropertyType String -Force
        New-ItemProperty -Path $psRegistryPath -Name "LockScreenImageUrl" -Value $newLockScreenImagePath -PropertyType String -Force
        Write-Host "Lock screen image path set successfully."
    }
    catch {
        Write-Error "Failed to set lock screen image: $_"
    }
}


Invoke-Command -ComputerName kgt-mi-hun868nb -Credential $cred -ScriptBlock {
    $username = "fel841"
    $newLockScreenImagePath = "C:\inst\a1.jpg"

    # Ensure image exists
    if (!(Test-Path $newLockScreenImagePath)) {
        Write-Error "Image file does not exist!"
        return
    }

    # Impersonate the user
    $userProfile = Get-CimInstance Win32_UserProfile | Where-Object { $_.LocalPath -like "*$username*" }
    
    # Switch to the user's context
    $userSid = $userProfile.SID
    $userRegPath = "HKEY_USERS\$userSid\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"

    # Convert to PowerShell registry path
    $psRegistryPath = "Registry::$userRegPath"

    # Check if registry path exists, create if not
    if (!(Test-Path -Path $psRegistryPath)) {
        try {
            New-Item -Path $psRegistryPath -Force | Out-Null
        }
        catch {
            Write-Error "Failed to create registry path: $_"
            return
        }
    }

    # Set lock screen image with multiple registry keys
    try {
        # Ensure full path is used
        $fullImagePath = Resolve-Path $newLockScreenImagePath

        # Multiple registry entries for lock screen
        New-ItemProperty -Path $psRegistryPath -Name "LockScreenImagePath" -Value $fullImagePath -PropertyType String -Force
        New-ItemProperty -Path $psRegistryPath -Name "LockScreenImageUrl" -Value $fullImagePath -PropertyType String -Force
        
        # Additional personalization settings
        New-ItemProperty -Path $psRegistryPath -Name "PersonalizedLockScreen" -Value 1 -PropertyType DWord -Force
        
        # Copy image to Windows Background Images folder
        $backgroundPath = "C:\Users\$username\AppData\Local\Microsoft\Windows\Background Images"
        New-Item -ItemType Directory -Path $backgroundPath -Force | Out-Null
        Copy-Item -Path $fullImagePath -Destination "$backgroundPath\LockScreen.jpg" -Force

        Write-Host "Lock screen image set successfully."
    }
    catch {
        Write-Error "Failed to set lock screen image: $_"
    }
}

