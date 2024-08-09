# Öffnen Sie eine Remote PowerShell-Sitzung
# Enter-PSSession -ComputerName "kgt-mi-ps" -Credential (Get-Credential)

# Schritt 1: Remote Desktop in der Registrierung aktivieren
Invoke-Command -ComputerName "kgt-mi-ps" -ScriptBlock {
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
}

# Schritt 2: Remote Desktop-Dienst starten und auf Automatisch setzen
Invoke-Command -ComputerName "kgt-mi-ps" -ScriptBlock {
    Get-Service -Name "TermService" | Set-Service -StartupType Automatic
    Start-Service -Name "TermService"
}

# Schritt 3: Firewall-Regel hinzufügen, um RDP zuzulassen
Invoke-Command -ComputerName "kgt-mi-ps" -ScriptBlock {
    Enable-NetFirewallRule -DisplayName "Remotedesktop - Benutzermodus (TCP eingehend)"
    Enable-NetFirewallRule -DisplayName "Remotedesktop - Benutzermodus (UDP eingehend)"
}

# Bestätigen Sie, dass die Änderungen erfolgreich waren
Invoke-Command -ComputerName "kgt-mi-ps" -ScriptBlock {
    $rdpStatus = Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections"
    $tcpFirewallRule = Get-NetFirewallRule -DisplayName "Remotedesktop - Benutzermodus (TCP eingehend)" | Where-Object { $_.Enabled -eq 'True' }
    $udpFirewallRule = Get-NetFirewallRule -DisplayName "Remotedesktop - Benutzermodus (UDP eingehend)" | Where-Object { $_.Enabled -eq 'True' }

    if ($rdpStatus.fDenyTSConnections -eq 0 -and $tcpFirewallRule -and $udpFirewallRule) {
        Write-Output "Remote Desktop ist aktiviert und die Firewall-Regeln sind konfiguriert."
    } else {
        Write-Output "Es gab ein Problem bei der Konfiguration von Remote Desktop oder der Firewall-Regeln."
    }
}

# Beenden Sie die Remote PowerShell-Sitzung
# Exit-PSSession

# nicht getestet
Enable-NetFirewallRule -DisplayGroup “RemoteDesktop”