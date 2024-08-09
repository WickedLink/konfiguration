# install dotnet hosting with switches and wait until execution has finished
# $exePath = "dotnet-hosting-3.1.28-win.exe"
$exePath = Resolve-Path -Path ".\dotnet-hosting-6.0.15\dotnet-hosting-6.0.15-win.exe"
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
$exePath = Resolve-Path -Path ".\dotnetfx48\ndp48-x86-x64-allos-enu.exe"
$arguments = "/q /norestart"
$process = Start-Process -FilePath $exePath -ArgumentList $arguments -Wait -PassThru
if ($process.ExitCode -ne 0) {
    Write-Host "Installation failed with exit code $($process.ExitCode)" -ForegroundColor Red
} else {
    Write-Host "Installation complete." -ForegroundColor Green
}

# install vcredist2019 with switches and wait until execution has finished
$exePath = Resolve-Path -Path ".\vcredist\VC_redist.x64.exe"
$arguments = "/install /quiet /norestart"
$process = Start-Process -FilePath $exePath -ArgumentList $arguments -Wait -PassThru
if ($process.ExitCode -ne 0) {
    Write-Host "Installation failed with exit code $($process.ExitCode)" -ForegroundColor Red
} else {
    Write-Host "Installation complete." -ForegroundColor Green
}

# install vcredist2019 with switches and wait until execution has finished
$exePath = Resolve-Path -Path ".\vcredist\VC_redist.x86.exe"
$arguments = "/install /quiet /norestart"
$process = Start-Process -FilePath $exePath -ArgumentList $arguments -Wait -PassThru
if ($process.ExitCode -ne 0) {
    Write-Host "Installation failed with exit code $($process.ExitCode)" -ForegroundColor Red
} else {
    Write-Host "Installation complete." -ForegroundColor Green
}

# install sqlServerOleDB and wait until execution has finished
# $msiPath = Resolve-Path -Path ".\sqlServerOleDB\DEU\msoledbsql.msi"
$msiPath = Resolve-Path -Path ".\sqlServerOleDB\msoledbsql.msi"
$arguments = "/i `"$msiPath`" /quiet /norestart IACCEPTMSOLEDBSQLLICENSETERMS=`"YES`""
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
# $arguments = "/p `"$msiPath`" /quiet /norestart REINSTALLMODE=`"ecmus`" REINSTALL=`"ALL`""
$arguments = "/p `"$msiPath`" /quiet /norestart REINSTALLMODE=`"omus`" REINSTALL=`"ALL`""
$process = Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -PassThru
if ($process.ExitCode -ne 0) {
    Write-Host "Installation failed with exit code $($process.ExitCode)" -ForegroundColor Red
} else {
    Write-Host "Installation complete." -ForegroundColor Green
}
