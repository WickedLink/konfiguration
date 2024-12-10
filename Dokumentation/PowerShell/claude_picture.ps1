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