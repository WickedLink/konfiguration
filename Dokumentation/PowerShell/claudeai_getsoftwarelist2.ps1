# Set the path to the text file containing computer names
$computerListPath = "C:\inst\ComputerList.txt"

# Set the path for the output CSV file
$outputCsvPath = "C:\inst\SoftwareInventory.csv"

# Assuming $cred is already defined before running this script
# $cred = Get-Credential

# Read the list of computers from the text file
$computers = Get-Content $computerListPath

# Create a hashtable to store results
$results = @{}

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
                    if (-not $results.ContainsKey($app.Name)) {
                        $results[$app.Name] = @{}
                    }
                    $results[$app.Name][$computer] = $app.Version
                }
                Write-Host "  Successfully retrieved software list from $computer" -ForegroundColor Green
            } else {
                Write-Host "  No software found on $computer" -ForegroundColor Yellow
            }
        }
        catch {
            $errorMessage = $_.Exception.Message -replace '["\r\n]', ''
            Write-Host ("  Error retrieving software list from {0}: {1}" -f $computer, $errorMessage) -ForegroundColor Red
        }
    }
    else {
        Write-Host "  $computer is not reachable" -ForegroundColor Yellow
    }

    Write-Host "" # Empty line for better readability
}

# Prepare the CSV data
$csvData = @()
$header = @("softwarename") + $computers

foreach ($software in $results.Keys | Sort-Object) {
    $row = @{softwarename = $software}
    foreach ($computer in $computers) {
        $row[$computer] = if ($results[$software].ContainsKey($computer)) { $results[$software][$computer] } else { "" }
    }
    $csvData += New-Object PSObject -Property $row
}

# Export results to CSV file
$csvData | Select-Object -Property $header | Export-Csv -Path $outputCsvPath -NoTypeInformation -Encoding UTF8

Write-Host "Script completed. Results have been exported to $outputCsvPath" -ForegroundColor Magenta
