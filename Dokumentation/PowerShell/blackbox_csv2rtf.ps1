# Define the input CSV file and the output RTF file
$csvFile = "C:\inst\computer_group_scan_20241126_140505.csv"
$rtfFile = "C:\inst\computer_group_scan_20241126_140505.rtf"

# Read the CSV file
$data = Import-Csv -Path $csvFile

# Start building the RTF content
$rtfContent = @"
{\rtf1
{\fonttbl{\f0\fnil\fcharset0 Arial;}}
\pard\fs20 This is a table created from a CSV file.\par
{\*\tbl}  % Begin the table
"@

# Add the header row
$headerRow = $true
$firstRow = $true

foreach ($row in $data) {
    if ($firstRow) {
        # Create header row
        $rtfContent += "{\trowd\trautofit1"
        foreach ($header in $row.PSObject.Properties.Name) {
            $rtfContent += "\cellx" + (2000 + 2000 * [Array]::IndexOf($row.PSObject.Properties.Name, $header))
            $rtfContent += "\cell \pard\fs20 $header\cell"
        }
        $rtfContent += "\row"  # End header row
        $firstRow = $false
    }

    # Create data rows
    $rtfContent += "{\trowd\trautofit1"
    foreach ($header in $row.PSObject.Properties.Name) {
        $rtfContent += "\cellx" + (2000 + 2000 * [Array]::IndexOf($row.PSObject.Properties.Name, $header))
        $rtfContent += "\cell \pard\fs20 $($row.$header)\cell"
    }
    $rtfContent += "\row"  # End data row
}

# End the table and finalize the RTF
$rtfContent += "}"
$rtfContent += "}"

# Write the RTF content to the output file
Set-Content -Path $rtfFile -Value $rtfContent -Encoding ASCII

Write-Host "RTF file created successfully at $rtfFile"