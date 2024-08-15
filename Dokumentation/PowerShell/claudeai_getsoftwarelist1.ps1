# Set the path to the text file containing computer names
$computerListPath = "C:\inst\ComputerList_updates.txt"

# Set the path for the output CSV file
$outputCsvPath = "C:\inst\SoftwareInventory.csv"

# Assuming $cred is already defined before running this script
# $cred = Get-Credential


# Read the list of computers from the text file
$computers = Get-Content $computerListPath

# Create an array to store results
$results = @()

# Loop through each computer in the list
foreach ($computer in $computers) {
    Write-Host "Processing computer: $computer" -ForegroundColor Cyan

    # Check if the computer is reachable
    if (Test-Connection -ComputerName $computer -Count 1 -Quiet) {
        Write-Host "  $computer is reachable. Retrieving software list..." -ForegroundColor Green

        try {
            # Get the list of installed software using Get-Package for both providers
            $software = Invoke-Command -ComputerName $computer -Credential $cred -ScriptBlock {
                $programsSoftware = Get-Package -ProviderName Programs -ErrorAction SilentlyContinue | Select-Object Name, Version
                $msiSoftware = Get-Package -ProviderName msi -ErrorAction SilentlyContinue | Select-Object Name, Version
                $programsSoftware + $msiSoftware | Sort-Object Name -Unique
            }

            if ($software) {
                foreach ($app in $software) {
                    $results += New-Object PSObject -Property @{
                        ComputerName = $computer
                        SoftwareName = $app.Name
                        Version = $app.Version
                        Status = "Success"
                    }
                }
                Write-Host "  Successfully retrieved software list from $computer" -ForegroundColor Green
            } else {
                Write-Host "  No software found on $computer" -ForegroundColor Yellow
                $results += New-Object PSObject -Property @{
                    ComputerName = $computer
                    SoftwareName = "No software found"
                    Version = "N/A"
                    Status = "Success - No software"
                }
            }
        }
        catch {
            $errorMessage = $_.Exception.Message -replace '["\r\n]', ''
            Write-Host ("  Error retrieving software list from {0}: {1}" -f $computer, $errorMessage) -ForegroundColor Red
            $results += New-Object PSObject -Property @{
                ComputerName = $computer
                SoftwareName = "N/A"
                Version = "N/A"
                Status = "Error: $errorMessage"
            }
        }
    }
    else {
        Write-Host "  $computer is not reachable" -ForegroundColor Yellow
        $results += New-Object PSObject -Property @{
            ComputerName = $computer
            SoftwareName = "N/A"
            Version = "N/A"
            Status = "Not reachable"
        }
    }

    Write-Host "" # Empty line for better readability
}

# Export results to CSV file
$results | Export-Csv -Path $outputCsvPath -NoTypeInformation -Encoding UTF8

Write-Host "Script completed. Results have been exported to $outputCsvPath" -ForegroundColor Magenta
