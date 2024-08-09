# Function to display colorful banners
function Show-Banner {
    param ([string]$Text)
    Write-Host "`n=======================================" -ForegroundColor Cyan
    Write-Host $Text -ForegroundColor Yellow
    Write-Host "=======================================`n" -ForegroundColor Cyan
}

# Function to install software
function Install-Software {
    param (
        [string]$Name,
        [string]$FilePath,
        [string]$Arguments,
        [string]$Installer = ""
    )
    
    Show-Banner "Installing $Name"
    
    Write-Host "Starting installation..." -ForegroundColor Yellow
    
    $resolvedPath = Resolve-Path -Path $FilePath -ErrorAction SilentlyContinue
    if (-not $resolvedPath) {
        Write-Host "Error: File not found - $FilePath" -ForegroundColor Red
        return $false
    }
    
    $installerPath = if ($Installer -eq "") { $resolvedPath } else { $Installer }
    
    # Replace #FilePath# placeholder with the actual resolved path
    $finalArguments = $Arguments -replace '#FilePath#', $resolvedPath

    Write-Host "Executing: $installerPath $finalArguments" -ForegroundColor Cyan
    
    $process = Start-Process -FilePath $installerPath -ArgumentList $finalArguments -Wait -PassThru -NoNewWindow
    
    if ($process.ExitCode -ne 0) {
        Write-Host "Installation of $Name failed with exit code $($process.ExitCode)" -ForegroundColor Red
        Write-Host "Error details:" -ForegroundColor Red
        if ($Installer -eq "msiexec.exe") {
            $msiErrors = @{
                1602 = "User canceled installation"
                1603 = "Fatal error during installation"
                1618 = "Another installation is already in progress"
                1619 = "Installation package could not be opened"
                1620 = "Installation package is not valid"
                1622 = "Error opening installation log file"
                1623 = "Language of this installation package is not supported by your system"
                1625 = "This installation is forbidden by system policy"
                1638 = "Another version of this product is already installed"
            }
            if ($msiErrors.ContainsKey($process.ExitCode)) {
                Write-Host $msiErrors[$process.ExitCode] -ForegroundColor Red
            } else {
                Write-Host "Unknown MSI error code" -ForegroundColor Red
            }
        } else {
            $exeErrors = @{
                1638 = "Another version of this product is already installed"
                3010 = "A restart is required to complete the installation"
                5100 = "The user's system does not meet the requirements"
            }
            if ($exeErrors.ContainsKey($process.ExitCode)) {
                Write-Host $exeErrors[$process.ExitCode] -ForegroundColor Red
            } else {
                Write-Host "Unknown error code" -ForegroundColor Red
            }
        }
        Write-Host "For more details, please check the application's log files or Windows Event Viewer." -ForegroundColor Yellow
    } else {
        Write-Host "Installation of $Name completed successfully." -ForegroundColor Green
    }
    
    Write-Host "Press any key to continue, or 'Q' to quit the installation process..." -ForegroundColor Yellow
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    if ($key.Character -eq 'q' -or $key.Character -eq 'Q') {
        return $false
    }
    return $true
}

# Main installation script
Clear-Host
Show-Banner "Software Installation Script"

$installations = @(
    @{Name=".NET 6.0 Hosting Bundle"; FilePath=".\dotnet-hosting-6.0.15\dotnet-hosting-6.0.15-win.exe"; Arguments="/install /quiet /norestart"},
    @{Name="SQL Server Compact Edition (x86)"; FilePath=".\sql server compact edition\SSCERuntime_x86-DEU.msi"; Arguments="/i `"#FilePath#`" /quiet /norestart"; Installer="msiexec.exe"},
    @{Name="SQL Server Compact Edition (x64)"; FilePath=".\sql server compact edition\SSCERuntime_x64-DEU.msi"; Arguments="/i `"#FilePath#`" /quiet /norestart"; Installer="msiexec.exe"},
    @{Name=".NET Framework 4.8"; FilePath=".\dotnetfx48\ndp48-x86-x64-allos-enu.exe"; Arguments="/q /norestart"},
    @{Name="Visual C++ Redistributable 2019 (x64)"; FilePath=".\vcredist\VC_redist.x64.exe"; Arguments="/install /quiet /norestart"},
    @{Name="Visual C++ Redistributable 2019 (x86)"; FilePath=".\vcredist\VC_redist.x86.exe"; Arguments="/install /quiet /norestart"},
    @{Name="SQL Server OLE DB Driver"; FilePath=".\sqlServerOleDB\msoledbsql.msi"; Arguments="/i `"#FilePath#`" /quiet /norestart IACCEPTMSOLEDBSQLLICENSETERMS=`"YES`""; Installer="msiexec.exe"},
    @{Name="Nova Setup"; FilePath=".\data\NovaSetup_x64.msi"; Arguments="/i `"#FilePath#`" /quiet /norestart"; Installer="msiexec.exe"},
    @{Name="Nova Patch"; FilePath=".\data\NovaPatch_x64.msp"; Arguments="/p `"#FilePath#`" /quiet /norestart REINSTALLMODE=`"omus`" REINSTALL=`"ALL`""; Installer="msiexec.exe"}
)

foreach ($installation in $installations) {
    $result = Install-Software @installation
    if (-not $result) {
        Write-Host "Installation process aborted by user." -ForegroundColor Yellow
        break
    }
}

Show-Banner "Installation Process Completed"
Write-Host "All requested software packages have been processed. Please check the output for any errors." -ForegroundColor Green
