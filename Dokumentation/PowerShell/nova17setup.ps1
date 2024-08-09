
# install dotnet hosting with switches and wait until execution has finished
# $exePath = "dotnet-hosting-3.1.28-win.exe"
$exePath = Resolve-Path -Path ".\dotnet-hosting-3.1.28\dotnet-hosting-3.1.28-win.exe"
$arguments = "/install /quiet /norestart"
$process = Start-Process -FilePath $exePath -ArgumentList $arguments -Wait -PassThru
if ($process.ExitCode -ne 0) {
    Write-Host "Installation failed with exit code $($process.ExitCode)" -ForegroundColor Red
} else {
    Write-Host "Installation complete." -ForegroundColor Green
}

# install SSCERuntime_x86-DEU.msi and wait until execution has finished
$msiPath = Resolve-Path -Path ".\sql server compact edition\SSCERuntime_x86-DEU.msi"
$arguments = "/i `"$msiPath`" /quiet /norestart"
$process = Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -PassThru
if ($process.ExitCode -ne 0) {
    Write-Host "Installation failed with exit code $($process.ExitCode)" -ForegroundColor Red
} else {
    Write-Host "Installation complete." -ForegroundColor Green
}

# install SSCERuntime_x64-DEU.msi and wait until execution has finished
$msiPath = Resolve-Path -Path ".\sql server compact edition\SSCERuntime_x64-DEU.msi"
$arguments = "/i `"$msiPath`" /quiet /norestart"
$process = Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -PassThru
if ($process.ExitCode -ne 0) {
    Write-Host "Installation failed with exit code $($process.ExitCode)" -ForegroundColor Red
} else {
    Write-Host "Installation complete." -ForegroundColor Green
}

# install dotnetfx with switches and wait until execution has finished
$exePath = Resolve-Path -Path ".\dotnetfx472\NDP472-KB4054530-x86-x64-AllOS-ENU.exe"
$arguments = "/q /norestart"
$process = Start-Process -FilePath $exePath -ArgumentList $arguments -Wait -PassThru
if ($process.ExitCode -ne 0) {
    Write-Host "Installation failed with exit code $($process.ExitCode)" -ForegroundColor Red
} else {
    Write-Host "Installation complete." -ForegroundColor Green
}

# install vcredist2019 with switches and wait until execution has finished
$exePath = Resolve-Path -Path ".\vcredist2019\VC_redist.x64.exe"
$arguments = "/install /quiet"
$process = Start-Process -FilePath $exePath -ArgumentList $arguments -Wait -PassThru
if ($process.ExitCode -ne 0) {
    Write-Host "Installation failed with exit code $($process.ExitCode)" -ForegroundColor Red
} else {
    Write-Host "Installation complete." -ForegroundColor Green
}

# install vcredist2019 with switches and wait until execution has finished
$exePath = Resolve-Path -Path ".\vcredist2019\VC_redist.x86.exe"
$arguments = "/install /quiet"
$process = Start-Process -FilePath $exePath -ArgumentList $arguments -Wait -PassThru
if ($process.ExitCode -ne 0) {
    Write-Host "Installation failed with exit code $($process.ExitCode)" -ForegroundColor Red
} else {
    Write-Host "Installation complete." -ForegroundColor Green
}

# install sqlServerOleDB and wait until execution has finished
$msiPath = Resolve-Path -Path ".\sqlServerOleDB\DEU\msoledbsql.msi"
$arguments = "/i `"$msiPath`" /quiet /norestart"
$process = Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -PassThru
if ($process.ExitCode -ne 0) {
    Write-Host "Installation failed with exit code $($process.ExitCode)" -ForegroundColor Red
} else {
    Write-Host "Installation complete." -ForegroundColor Green
}

# install nova and wait until execution has finished
$msiPath = Resolve-Path -Path ".\data\NovaSetup_x64.msi"
$arguments = "/i `"$msiPath`" /quiet /norestart"
$process = Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -PassThru
if ($process.ExitCode -ne 0) {
    Write-Host "Installation failed with exit code $($process.ExitCode)" -ForegroundColor Red
} else {
    Write-Host "Installation complete." -ForegroundColor Green
}

# msiexec.exe /p "C:\MyPatch.msp" /qb REINSTALLMODE="ecmus" REINSTALL="ALL"
# $arguments = "/p `"$msiPath`" /quiet /norestart REINSTALLMODE=`"ecmus`" REINSTALL=`"ALL`""

# install nova patch and wait until execution has finished
$msiPath = Resolve-Path -Path ".\data\NovaPatch_x64.msp"
# $arguments = "/p `"$msiPath`" /quiet /norestart REINSTALLMODE="ecmus" REINSTALL="ALL""
$arguments = "/p `"$msiPath`" /quiet /norestart REINSTALLMODE=`"ecmus`" REINSTALL=`"ALL`""
$process = Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -PassThru
if ($process.ExitCode -ne 0) {
    Write-Host "Installation failed with exit code $($process.ExitCode)" -ForegroundColor Red
} else {
    Write-Host "Installation complete." -ForegroundColor Green
}








# Define the paths to the MSI and MSP files
$subDirectory = ".\data"
$msiPath = Join-Path -Path $subDirectory -ChildPath "NovaSetup_x64.msi"
$mspPath = Join-Path -Path $subDirectory -ChildPath "NovaPatch_x64.msp"

# Check if the MSI file exists
if (Test-Path -Path $msiPath) {
    Write-Output "MSI file found: $msiPath"

    # Install the MSI package silently
    Start-Process msiexec.exe -ArgumentList "/i `"$msiPath`" /quiet /norestart" -Wait

    # Check if the MSI installation was successful
    if ($LASTEXITCODE -eq 0) {
        # Check if the MSP file exists
        if (Test-Path -Path $mspPath) {
            Write-Output "MSP file found: $mspPath"

            # Apply the MSP patch silently
            Start-Process msiexec.exe -ArgumentList "/p `"$mspPath`" /quiet /norestart" -Wait

            # Check if the MSP application was successful
            if ($LASTEXITCODE -eq 0) {
                Write-Output "MSI installation and MSP patch application completed successfully."
            } else {
                Write-Output "MSP patch application failed with exit code $LASTEXITCODE."
            }
        } else {
            Write-Output "MSP file not found: $mspPath"
        }
    } else {
        Write-Output "MSI installation failed with exit code $LASTEXITCODE."
    }
} else {
    Write-Output "MSI file not found: $msiPath"
}
