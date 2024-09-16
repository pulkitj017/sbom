# Define file paths
$licensesFile = "formatted-licenses.txt"
$outdatedFile = "formatted-outdated.txt"
$outputFile = "sbom-result.txt"

# Read and process licenses file
$licenses = Get-Content $licensesFile | ForEach-Object {
    if ($_ -notmatch '^Dependency\s+Version\s+License' -and $_ -notmatch '^-+$') {
        $fields = $_ -split '\s{2,}'
        if ($fields.Length -ge 3) {
            [PSCustomObject]@{
                Dependency = $fields[0].Trim()
                Version = $fields[1].Trim()
                License = $fields[2].Trim()
            }
        }
    }
}

# Read and process outdated file
$outdated = Get-Content $outdatedFile | ForEach-Object {
    if ($_ -notmatch '^Dependency\s+Current\s+Latest' -and $_ -notmatch '^-+$') {
        $fields = $_ -split '\s{2,}'
        if ($fields.Length -ge 3) {
            [PSCustomObject]@{
                Dependency = $fields[0].Trim()
                CurrentVersion = $fields[1].Trim()
                LatestVersion = $fields[2].Trim()
            }
        }
    }
}

# Initialize the output list
$output = @()

# Process licenses file
foreach ($license in $licenses) {
    $outdatedDep = $outdated | Where-Object { $_.Dependency -eq $license.Dependency }
    
    if ($outdatedDep) {
        $output += [PSCustomObject]@{
            Dependency = $license.Dependency
            CurrentVersion = $outdatedDep.CurrentVersion
            LatestVersion = $outdatedDep.LatestVersion
            License = $license.License
        }
    } else {
        # If not found in outdated file, set LatestVersion as CurrentVersion from license file
        $output += [PSCustomObject]@{
            Dependency = $license.Dependency
            CurrentVersion = $license.Version
            LatestVersion = $license.Version
            License = $license.License
        }
    }
}

# Add entries from outdated file that are not in the licenses file
foreach ($outdatedDep in $outdated) {
    if (-not ($licenses | Where-Object { $_.Dependency -eq $outdatedDep.Dependency })) {
        $output += [PSCustomObject]@{
            Dependency = $outdatedDep.Dependency
            CurrentVersion = $outdatedDep.CurrentVersion
            LatestVersion = $outdatedDep.LatestVersion
            License = "N/A"
        }
    }
}

# Write the output to the file
$output | Sort-Object Dependency | Format-Table -AutoSize | Out-File $outputFile
