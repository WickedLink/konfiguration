# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Function to write colorful, formatted messages
function Write-ColorfulMessage {
    param (
        [string]$Message,
        [string]$ForegroundColor = "White",
        [string]$BackgroundColor = "Black",
        [switch]$NoNewline
    )
    Write-Host "`n[" -NoNewline
    Write-Host (Get-Date -Format "HH:mm:ss") -ForegroundColor Cyan -NoNewline
    Write-Host "] " -NoNewline
    if ($NoNewline) {
        Write-Host $Message -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor -NoNewline
    } else {
        Write-Host $Message -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
    }
}

Write-ColorfulMessage "Welcome to the Remote File Installer/Extractor!" "Green"
Write-ColorfulMessage "=========================================" "Green"

# Create an OpenFileDialog instance
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog

# Set initial properties
$OpenFileDialog.InitialDirectory = "C:\"
$OpenFileDialog.Filter = "All files (*.*)|*.*"
$OpenFileDialog.FilterIndex = 1
$OpenFileDialog.Multiselect = $false

Write-ColorfulMessage "Please select a file to process..." "Yellow"
# Show the dialog and get the selected file
$DialogResult = $OpenFileDialog.ShowDialog()

if ($DialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
    $FilePath = $OpenFileDialog.FileName
    Write-ColorfulMessage "Selected file: $FilePath" "Green"
} else {
    Write-ColorfulMessage "File selection was cancelled." "Red"
    exit
}

# Read the list of remote computers from a file
$ComputerListFile = "c:\inst\computerlist.txt"
Write-ColorfulMessage "Reading computer list from: $ComputerListFile" "Yellow"
$Computers = Get-Content -Path $ComputerListFile

if ($Computers.Count -eq 0) {
    Write-ColorfulMessage "No computers found in the list." "Red"
    exit
} elseif ($Computers.Count -eq 1) {
    $SelectedComputer = $Computers[0]
    Write-ColorfulMessage "Only one computer in the list. Automatically selected: $SelectedComputer" "Green"
} else {
    # Display the list of computers and ask the user to select one
    Write-ColorfulMessage "Select a computer from the list:" "Yellow"
    for ($i = 0; $i -lt $Computers.Count; $i++) {
        Write-Host "[$($i + 1)] $($Computers[$i])"
    }

    do {
        $Selection = Read-Host "Enter the number of the computer you want to select"
        
        # Check if the input is a valid number and within range
        $ValidSelection = $Selection -as [int]
        if ($ValidSelection -and $ValidSelection -gt 0 -and $ValidSelection -le $Computers.Count) {
            $SelectedComputer = $Computers[$ValidSelection - 1]  # Adjust for 0-based index
            Write-ColorfulMessage "Selected computer: $SelectedComputer" "Green"
            break
        } else {
            Write-ColorfulMessage "Invalid selection. Please enter a valid number." "Red"
        }
    } while ($true)
}

# Define the folder path on the remote computer where to copy the install package
$DestFolderPath = "c:\inst"

Write-ColorfulMessage "Preparing remote computer..." "Yellow"
Invoke-Command -ComputerName $SelectedComputer -ScriptBlock {
    param($DestFolderPath)
    if (!(Test-Path $DestFolderPath)) {
        New-Item $DestFolderPath -ItemType Directory | Out-Null
        Write-Host "Created directory: $DestFolderPath"
    } else {
        Write-Host "Directory already exists: $DestFolderPath"
    }
} -ArgumentList $DestFolderPath -Credential $cred

# Create a network share for the destination folder
$ShareName = "inst_share"
Write-ColorfulMessage "Creating temporary network share..." "Yellow"
Invoke-Command -ComputerName $SelectedComputer -ScriptBlock {
    param($DestFolderPath, $ShareName)
    New-SmbShare -Name $ShareName -Path $DestFolderPath -FullAccess "Jeder"
    Write-Host "Created network share: $ShareName"
} -ArgumentList $DestFolderPath, $ShareName -Credential $cred

# Copy the file to the network share using Robocopy
$SharePath = "\\$SelectedComputer\$ShareName"
Write-ColorfulMessage "Copying file to remote computer..." "Yellow"
Robocopy $(Split-Path $FilePath) $SharePath $(Split-Path $FilePath -Leaf) /z

# Check if the copied file is an MSI file or a ZIP archive
$CopiedFilePath = Join-Path $DestFolderPath $(Split-Path $FilePath -Leaf)
if ($CopiedFilePath -like "*.msi") {
    Write-ColorfulMessage "The copied file is an MSI file." "Cyan"
    $InstallRemotely = Read-Host "Do you want to install it remotely? (yes/no)"
    if ($InstallRemotely -eq "yes") {
        Write-ColorfulMessage "Installing the MSI file on $SelectedComputer..." "Yellow"
        Invoke-Command -ComputerName $SelectedComputer -ScriptBlock {
            param($CopiedFilePath)
            Write-Host "Starting MSI installation..."
            $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$CopiedFilePath`" /quiet /norestart" -Wait -PassThru
            if ($process.ExitCode -ne 0) {
                Write-Host "Installation failed with exit code $($process.ExitCode)" -ForegroundColor Red
            } else {
                Write-Host "Installation complete." -ForegroundColor Green
            }
        } -ArgumentList $CopiedFilePath -Credential $cred
    } else {
        Write-ColorfulMessage "Not installing the MSI file remotely." "Yellow"
    }
} elseif ($CopiedFilePath -like "*.zip") {
    Write-ColorfulMessage "The copied file is a ZIP archive." "Cyan"
    $UnzipRemotely = Read-Host "Do you want to unzip it remotely? (yes/no)"
    if ($UnzipRemotely -eq "yes") {
        # Determine the folder name based on the ZIP file name
        $ZipFolderName = [System.IO.Path]::GetFileNameWithoutExtension($CopiedFilePath)
        $UnzipDestPath = Join-Path $DestFolderPath $ZipFolderName

        Write-ColorfulMessage "Unzipping the ZIP archive on $SelectedComputer to folder: $UnzipDestPath" "Yellow"
        Invoke-Command -ComputerName $SelectedComputer -ScriptBlock {
            param($CopiedFilePath, $UnzipDestPath)
            
            # Check if 7-Zip is installed
            $7zipPath = "C:\Program Files\7-Zip\7z.exe"
            if (Test-Path $7zipPath) {
                Write-Host "7-Zip found. Using it for extraction."
                # Create the destination directory if it doesn't exist
                if (!(Test-Path $UnzipDestPath)) {
                    New-Item -ItemType Directory -Path $UnzipDestPath | Out-Null
                    Write-Host "Created extraction directory: $UnzipDestPath"
                }
                
                # Use 7-Zip to extract the archive
                Write-Host "Starting 7-Zip extraction..."
                $process = Start-Process -FilePath $7zipPath -ArgumentList "x `"$CopiedFilePath`" -o`"$UnzipDestPath`" -y -bb3" -NoNewWindow -PassThru -Wait
                if ($process.ExitCode -eq 0) {
                    Write-Host "Unzipping complete." -ForegroundColor Green
                } else {
                    Write-Host "Unzipping failed with exit code $($process.ExitCode)" -ForegroundColor Red
                }
            } else {
                Write-Host "7-Zip not found. Falling back to built-in ZIP extraction." -ForegroundColor Yellow
                Add-Type -AssemblyName System.IO.Compression.FileSystem
                [System.IO.Compression.ZipFile]::ExtractToDirectory($CopiedFilePath, $UnzipDestPath)
                Write-Host "Unzipping complete." -ForegroundColor Green
            }
        } -ArgumentList $CopiedFilePath, $UnzipDestPath -Credential $cred
    } else {
        Write-ColorfulMessage "Not unzipping the ZIP archive remotely." "Yellow"
    }
} else {
    Write-ColorfulMessage "The copied file is not an MSI file or a ZIP archive." "Magenta"
}

# Remove the network share
Write-ColorfulMessage "Cleaning up: Removing temporary network share..." "Yellow"
Invoke-Command -ComputerName $SelectedComputer -ScriptBlock {
    param($ShareName)
    Remove-SmbShare -Name $ShareName -Force
    Write-Host "Removed network share: $ShareName"
} -ArgumentList $ShareName -Credential $cred

Write-ColorfulMessage "Operation completed successfully!" "Green"
Write-ColorfulMessage "===============================" "Green"
