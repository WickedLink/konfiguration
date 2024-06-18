# Define the software installation package path
# $FilePath = "C:\inst\pdfxve10.exe"
$FilePath = "C:\inst\7z2406-x64.exe"
# Define the folder path on the remote computer where to copy the install package
$DestFolderPath = "C:\inst"
# Read the list of remote computers from a file
$ComputerNames = Get-Content "C:\inst\ComputerList.txt"

# Iterate through each remote computer and deploy the Software
foreach ($ComputerName in $ComputerNames) {
    # Crea a new PowerShell session to the remote computer
    $Session = New-PSSession -ComputerName $ComputerName -Credential $cred
    
    # Create the destination folder if it doesn't already exist on the remote computer
    Invoke-Command -Session $Session -ScriptBlock {
        param($DestFolderPath)
        if (!(Test-Path $DestFolderPath)) {
            New-Item $DestFolderPath -ItemType Directory # | Out-Null
        }
    } -ArgumentList $DestFolderPath

    # Copy the software installation package to the remote computer
    Copy-Item $FilePath -Destination $DestFolderPath -ToSession $Session
    
    # Install the Software silently on the remote computer
    Invoke-Command -Session $Session -ScriptBlock {
        param($FilePath)
        Start-Process -FilePath $FilePath -ArgumentList "/S" -Wait
    } -ArgumentList $FilePath
    
    # Remove the installation package from the remote computer
    Invoke-Command -Session $Session -ScriptBlock {
        param($FilePath)
        Remove-Item $FilePath -Force -Recurse
    } -ArgumentList $FilePath
    
    # Close the PowerShell session to the remote computer
    Remove-PSSession $Session
}
