
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
            
            # Check if 7-Zip is installed
            $7zipPath = "C:\Program Files\7-Zip\7z.exe"
            if (Test-Path $7zipPath) {
                # Create the destination directory if it doesn't exist
                if (!(Test-Path $UnzipDestPath)) {
                    New-Item -ItemType Directory -Path $UnzipDestPath | Out-Null
                }
                
                # Use 7-Zip to extract the archive
                $process = Start-Process -FilePath $7zipPath -ArgumentList "x `"$CopiedFilePath`" -o`"$UnzipDestPath`" -y" -NoNewWindow -PassThru -Wait
                if ($process.ExitCode -eq 0) {
                    Write-Host "Unzipping complete." -ForegroundColor Green
                } else {
                    Write-Host "Unzipping failed with exit code $($process.ExitCode)" -ForegroundColor Red
                }
            } else {
                Write-Host "7-Zip is not installed at the expected location. Falling back to built-in ZIP extraction." -ForegroundColor Yellow
                Add-Type -AssemblyName System.IO.Compression.FileSystem
                [System.IO.Compression.ZipFile]::ExtractToDirectory($CopiedFilePath, $UnzipDestPath)
                Write-Host "Unzipping complete." -ForegroundColor Green
            }
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

