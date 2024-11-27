# Computer Group Membership Scanner
# Scans computers from a list and retrieves local group memberships

function Scan-ComputerGroups {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,
        
        [Parameter(Mandatory=$false)]
        [System.Management.Automation.PSCredential]$Credential
    )

    # Remove any trailing ':' and trim whitespace
    $ComputerName = $ComputerName.TrimEnd(':').Trim()

    # Initialize results array
    $computerResults = @()

    try {
        # Test connection
        Write-Host "Testing connection to $ComputerName" -ForegroundColor Yellow
        if (-not (Test-Connection -ComputerName $ComputerName -Count 2 -Quiet)) {
            Write-Host "❌ $ComputerName is not reachable" -ForegroundColor Red
            return $null
        }
        Write-Host "✅ $ComputerName is reachable" -ForegroundColor Green

        # Define the groups to check (in German)
        $groupsToCheck = @('Administratoren', 'Benutzer')

        # Scan groups using Invoke-Command for remote execution
        foreach ($group in $groupsToCheck) {
            try {
                Write-Host "Retrieving members of group $group on $ComputerName" -ForegroundColor Yellow
                
                # Use Invoke-Command to run locally on remote computer
                $groupMembers = if ($Credential) {
                    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
                        param($groupName)
                        Get-LocalGroupMember -Group $groupName
                    } -ArgumentList $group
                }
                else {
                    Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                        param($groupName)
                        Get-LocalGroupMember -Group $groupName
                    } -ArgumentList $group
                }

                # Process and store group members
                foreach ($member in $groupMembers) {
                    $computerResults += [PSCustomObject]@{
                        ComputerName = $ComputerName
                        Group = $group
                        MemberName = $member.Name
                        MemberType = $member.ObjectClass
                    }
                }

                Write-Host "📋 Found $($groupMembers.Count) members in $group group" -ForegroundColor Cyan
            }
            catch {
                Write-Host "❌ Error retrieving $group group: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    catch {
        Write-Host "❌ Unexpected error scanning ${ComputerName}: $($_.Exception.Message)" -ForegroundColor Red
    }

    return $computerResults
}

# Main script execution
function Main {
    # Read computer list
    $computerList = Get-Content -Path "c:\inst\computerlist_all.txt"
    Write-Host "Loaded $($computerList.Count) computers from computerlist_all.txt" -ForegroundColor Magenta

    # Prepare results collection
    $allResults = @()

    # Scan each computer
    foreach ($computer in $computerList) {
        Write-Host "`n🖥️ Scanning Computer: $computer" -ForegroundColor Magenta
        
        # Use $cred if defined (you'll define this before running the script)
        $result = Scan-ComputerGroups -ComputerName $computer -Credential $cred
        
        if ($result) {
            $allResults += $result
        }
    }

    # Export to CSV
    $outputPath = "computer_group_scan_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    $allResults | Export-Csv -Path $outputPath -NoTypeInformation
    Write-Host "💾 Results exported to $outputPath" -ForegroundColor Green
}

# Run the main function
Main