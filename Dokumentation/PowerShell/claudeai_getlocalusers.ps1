# Computer Group Membership Scanner
# Scans computers from a list and retrieves local group memberships

# Ensure verbose output
$VerbosePreference = 'Continue'

# Check and import necessary modules
function Ensure-RequiredModules {
    $modulesToCheck = @('ActiveDirectory', 'PSLogging')
    
    foreach ($module in $modulesToCheck) {
        Write-Verbose "Checking for module: $module"
        if (-not (Get-Module -ListAvailable -Name $module)) {
            Write-Warning "Module $module is not installed. Attempting to install..."
            try {
                Install-Module -Name $module -Force -Scope CurrentUser
                Import-Module -Name $module
                Write-Verbose "Successfully installed and imported $module"
            }
            catch {
                Write-Error "Failed to install module $module. Error: $_"
            }
        }
        else {
            Import-Module -Name $module
            Write-Verbose "Module $module is already installed and imported"
        }
    }
}

# Main scanning function
function Scan-ComputerGroups {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,
        
        [Parameter(Mandatory=$false)]
        [System.Management.Automation.PSCredential]$Credential
    )

    # Colorful output function
    function Write-ColorOutput {
        param(
            [string]$Message,
            [string]$Color = 'Green'
        )
        Write-Host $Message -ForegroundColor $Color
    }

    # Initialize results array
    $computerResults = @()

    try {
        # Test connection
        Write-Verbose "Testing connection to $ComputerName"
        if (-not (Test-Connection -ComputerName $ComputerName -Count 2 -Quiet)) {
            Write-ColorOutput "❌ $ComputerName is not reachable" -Color 'Red'
            return $null
        }
        Write-ColorOutput "✅ $ComputerName is reachable" -Color 'Green'

        # Define the groups to check (in German)
        $groupsToCheck = @('Administratoren', 'Benutzer')

        # Scan groups
        foreach ($group in $groupsToCheck) {
            try {
                Write-Verbose "Retrieving members of group $group on $ComputerName"
                
                # Use the credential if provided
                $groupMembers = if ($Credential) {
                    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
                        param($groupName)
                        Get-LocalGroupMember -Group $groupName
                    } -ArgumentList $group
                }
                else {
                    Get-LocalGroupMember -ComputerName $ComputerName -Group $group
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

                Write-ColorOutput "📋 Found $($groupMembers.Count) members in $group group" -Color 'Cyan'
            }
            catch {
                Write-ColorOutput "❌ Error retrieving $group group: $($_.Exception.Message)" -Color 'Red'
            }
        }
    }
    catch {
        Write-ColorOutput "❌ Unexpected error scanning ${ComputerName}: $($_.Exception.Message)" -Color 'Red'
    }

    return $computerResults
}

# Main script execution
function Main {
    # Ensure required modules are imported
    Ensure-RequiredModules

    # Read computer list
    $computerList = Get-Content -Path "computerlist_all.txt"
    Write-Verbose "Loaded $($computerList.Count) computers from computerlist_all.txt"

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
    Write-ColorOutput "💾 Results exported to $outputPath" -Color 'Green'
}

# Run the main function
Main