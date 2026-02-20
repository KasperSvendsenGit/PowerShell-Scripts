# PowerShell Script to Find Folders with Non-Inherited Permissions
# Requires: PowerShell 5.0 or higher, appropriate read permissions on target folders

param(
    [Parameter(Mandatory=$false)]
    [string]$RootFolder = "E:\Shares\_Arkiv",  # Set your default path here
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "C:\Scripts\FilePermissionsAudit_Reports\FilePermissionsAuditReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
)

# Initialize collections
$FoldersWithCustomPermissions = @()
$ErrorLog = @()
$ProcessedCount = 0
$TotalFolders = 0

Write-Host "Starting permissions audit on: $RootFolder" -ForegroundColor Cyan
Write-Host "This may take some time depending on the folder structure..." -ForegroundColor Yellow

# Function to check if folder has non-inherited permissions
function Test-NonInheritedPermissions {
    param([string]$Path)
    
    try {
        $acl = Get-Acl -Path $Path -ErrorAction Stop
        $hasNonInherited = $false
        
        foreach ($access in $acl.Access) {
            if (-not $access.IsInherited) {
                $hasNonInherited = $true
                break
            }
        }
        
        # Also check if inheritance is disabled
        if ($acl.AreAccessRulesProtected) {
            $hasNonInherited = $true
        }
        
        return $hasNonInherited
    }
    catch {
        $script:ErrorLog += [PSCustomObject]@{
            Path = $Path
            Error = $_.Exception.Message
        }
        return $false
    }
}

# Function to get permission details
function Get-PermissionDetails {
    param([string]$Path)
    
    try {
        $acl = Get-Acl -Path $Path -ErrorAction Stop
        $permissions = @()
        
        foreach ($access in $acl.Access) {
            if (-not $access.IsInherited) {
                $permissions += [PSCustomObject]@{
                    Identity = $access.IdentityReference.Value
                    Rights = $access.FileSystemRights
                    AccessType = $access.AccessControlType
                    IsInherited = $access.IsInherited
                    InheritanceFlags = $access.InheritanceFlags
                    PropagationFlags = $access.PropagationFlags
                }
            }
        }
        
        return $permissions
    }
    catch {
        return @()
    }
}

# Main processing loop
try {
    # Get all folders recursively
    $allFolders = Get-ChildItem -Path $RootFolder -Directory -Recurse -ErrorAction SilentlyContinue
    $TotalFolders = ($allFolders | Measure-Object).Count + 1  # +1 for root folder
    
    Write-Host "Found $TotalFolders folders to process..." -ForegroundColor Green
    
    # Check root folder first
    Write-Progress -Activity "Scanning Folders" -Status "Processing: $RootFolder" -PercentComplete 0
    if (Test-NonInheritedPermissions -Path $RootFolder) {
        $permissions = Get-PermissionDetails -Path $RootFolder
        $owner = (Get-Acl -Path $RootFolder).Owner
        
        $FoldersWithCustomPermissions += [PSCustomObject]@{
            FolderPath = $RootFolder
            Owner = $owner
            InheritanceDisabled = (Get-Acl -Path $RootFolder).AreAccessRulesProtected
            PermissionCount = $permissions.Count
            Permissions = $permissions
            LastModified = (Get-Item $RootFolder).LastWriteTime
        }
    }
    $ProcessedCount++
    
    # Process all subfolders
    foreach ($folder in $allFolders) {
        $ProcessedCount++
        $percentComplete = [math]::Round(($ProcessedCount / $TotalFolders) * 100, 2)
        
        Write-Progress -Activity "Scanning Folders" -Status "Processing: $($folder.Name)" -PercentComplete $percentComplete
        
        if (Test-NonInheritedPermissions -Path $folder.FullName) {
            $permissions = Get-PermissionDetails -Path $folder.FullName
            $owner = (Get-Acl -Path $folder.FullName).Owner
            
            $FoldersWithCustomPermissions += [PSCustomObject]@{
                FolderPath = $folder.FullName
                Owner = $owner
                InheritanceDisabled = (Get-Acl -Path $folder.FullName).AreAccessRulesProtected
                PermissionCount = $permissions.Count
                Permissions = $permissions
                LastModified = $folder.LastWriteTime
            }
        }
    }
}
catch {
    Write-Host "Error during scan: $_" -ForegroundColor Red
}
finally {
    Write-Progress -Activity "Scanning Folders" -Completed
}

Write-Host "`nScan complete!" -ForegroundColor Green
Write-Host "Processed: $ProcessedCount folders" -ForegroundColor Cyan
Write-Host "Found: $($FoldersWithCustomPermissions.Count) folders with non-inherited permissions" -ForegroundColor Yellow
Write-Host "Errors: $($ErrorLog.Count)" -ForegroundColor $(if ($ErrorLog.Count -gt 0) { 'Red' } else { 'Green' })

# Generate HTML Report
$htmlReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>Folder Permissions Audit Report</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        h1 {
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
        }
        .summary {
            background-color: #ecf0f1;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .summary-item {
            display: inline-block;
            margin-right: 30px;
            padding: 10px;
            background-color: white;
            border-radius: 3px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        th {
            background-color: #3498db;
            color: white;
            padding: 12px;
            text-align: left;
            position: sticky;
            top: 0;
        }
        td {
            padding: 10px;
            border-bottom: 1px solid #ecf0f1;
        }
        tr:hover {
            background-color: #f8f9fa;
        }
        .folder-path {
            font-family: 'Courier New', monospace;
            font-size: 12px;
            color: #2c3e50;
        }
        .inheritance-disabled {
            background-color: #e74c3c;
            color: white;
            padding: 2px 8px;
            border-radius: 3px;
            font-size: 11px;
        }
        .inheritance-enabled {
            background-color: #27ae60;
            color: white;
            padding: 2px 8px;
            border-radius: 3px;
            font-size: 11px;
        }
        .permissions-list {
            font-size: 11px;
            max-height: 100px;
            overflow-y: auto;
            background-color: #f8f9fa;
            padding: 5px;
            border-radius: 3px;
        }
        .permission-item {
            margin-bottom: 3px;
            padding: 2px;
            background-color: white;
            border-left: 3px solid #3498db;
            padding-left: 8px;
        }
        .error-section {
            margin-top: 30px;
            background-color: #fff5f5;
            border: 1px solid #ffcccc;
            padding: 15px;
            border-radius: 5px;
        }
        .error-item {
            color: #cc0000;
            margin-bottom: 5px;
        }
        .timestamp {
            color: #7f8c8d;
            font-size: 12px;
            margin-top: 20px;
            text-align: center;
        }
    </style>
</head>
<body>
    <h1>Folder Permissions Audit Report</h1>
    
    <div class="summary">
        <div class="summary-item">
            <strong>Root Path:</strong><br>$RootFolder
        </div>
        <div class="summary-item">
            <strong>Total Folders Scanned:</strong><br>$ProcessedCount
        </div>
        <div class="summary-item">
            <strong>Folders with Custom Permissions:</strong><br>$($FoldersWithCustomPermissions.Count)
        </div>
        <div class="summary-item">
            <strong>Scan Errors:</strong><br>$($ErrorLog.Count)
        </div>
        <div class="summary-item">
            <strong>Report Generated:</strong><br>$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
        </div>
    </div>
    
    <h2>Folders with Non-Inherited Permissions</h2>
    <table>
        <thead>
            <tr>
                <th>Folder Path</th>
                <th>Owner</th>
                <th>Inheritance</th>
                <th>Custom Permissions</th>
                <th>Last Modified</th>
            </tr>
        </thead>
        <tbody>
"@

# Add folder entries to HTML
foreach ($folder in $FoldersWithCustomPermissions | Sort-Object FolderPath) {
    $inheritanceStatus = if ($folder.InheritanceDisabled) { 
        '<span class="inheritance-disabled">DISABLED</span>' 
    } else { 
        '<span class="inheritance-enabled">MODIFIED</span>' 
    }
    
    $permissionsHtml = '<div class="permissions-list">'
    foreach ($perm in $folder.Permissions) {
        $permissionsHtml += @"
        <div class="permission-item">
            <strong>$($perm.Identity)</strong><br>
            $($perm.AccessType): $($perm.Rights)<br>
            Inherit: $($perm.InheritanceFlags) | Propagate: $($perm.PropagationFlags)
        </div>
"@
    }
    $permissionsHtml += '</div>'
    
    $htmlReport += @"
            <tr>
                <td class="folder-path">$($folder.FolderPath)</td>
                <td>$($folder.Owner)</td>
                <td>$inheritanceStatus</td>
                <td>$permissionsHtml</td>
                <td>$($folder.LastModified.ToString('yyyy-MM-dd HH:mm'))</td>
            </tr>
"@
}

$htmlReport += @"
        </tbody>
    </table>
"@

# Add error section if there were errors
if ($ErrorLog.Count -gt 0) {
    $htmlReport += @"
    <div class="error-section">
        <h3>Scan Errors ($($ErrorLog.Count))</h3>
        <div>
"@
    foreach ($error in $ErrorLog) {
        $htmlReport += @"
            <div class="error-item">
                <strong>Path:</strong> $($error.Path)<br>
                <strong>Error:</strong> $($error.Error)
            </div>
"@
    }
    $htmlReport += @"
        </div>
    </div>
"@
}

$htmlReport += @"
    <div class="timestamp">
        Report generated on $(Get-Date -Format 'dddd, MMMM dd, yyyy') at $(Get-Date -Format 'HH:mm:ss')
    </div>
</body>
</html>
"@

# Save HTML report
try {
    $htmlReport | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "`nHTML report saved to: $OutputPath" -ForegroundColor Green
    
    # Optionally open the report
    # $openReport = Read-Host "`nDo you want to open the report now? (Y/N)"
    # if ($openReport -eq 'Y' -or $openReport -eq 'y') {
    #    Start-Process $OutputPath
    #}
}
catch {
    Write-Host "Error saving HTML report: $_" -ForegroundColor Red
}

# Display summary
Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Total folders scanned: $ProcessedCount"
Write-Host "Folders with custom permissions: $($FoldersWithCustomPermissions.Count)"
if ($FoldersWithCustomPermissions.Count -gt 0) {
    Write-Host "`nTop 5 folders with most custom permissions:" -ForegroundColor Yellow
    $FoldersWithCustomPermissions | Sort-Object PermissionCount -Descending | Select-Object -First 5 | ForEach-Object {
        Write-Host "  - $($_.FolderPath) ($($_.PermissionCount) custom permissions)"
    }
}