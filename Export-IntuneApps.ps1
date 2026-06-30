#Requires -Modules Microsoft.Graph.Authentication

<#
.SYNOPSIS
    Exports all properties for all Intune mobile apps to a JSON and CSV file.

.DESCRIPTION
    Connects to Microsoft Graph and retrieves all Intune managed apps
    with their full properties, then exports to JSON (complete data)
    and CSV (flattened summary).

.NOTES
    Prerequisites:
      - Install-Module Microsoft.Graph.Authentication
      - An Entra ID account with at least Intune Reader / DeviceManagementApps.Read.All permission

    Usage:
      .\Export-IntuneApps.ps1
      .\Export-IntuneApps.ps1 -OutputPath "C:\Reports"
      .\Export-IntuneApps.ps1 -UseManagedIdentity   # For automation (Azure runbook etc.)
#>

[CmdletBinding()]
param(
    [string]$OutputPath = ".",
    [switch]$UseManagedIdentity
)

$ErrorActionPreference = "Stop"
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"

# ── Connect to Graph ──────────────────────────────────────────────
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan

$graphParams = @{
    Scopes = @("DeviceManagementApps.Read.All")
}

if ($UseManagedIdentity) {
    $graphParams = @{ Identity = $true }
}

Connect-MgGraph @graphParams
Write-Host "Connected successfully.`n" -ForegroundColor Green

# ── Retrieve all apps with pagination ─────────────────────────────
Write-Host "Retrieving Intune apps..." -ForegroundColor Cyan

$baseUri = "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps"
$allApps = [System.Collections.Generic.List[object]]::new()
$nextLink = $baseUri

while ($nextLink) {
    $response = Invoke-MgGraphRequest -Method GET -Uri $nextLink
    
    if ($response.value) {
        $response.value | ForEach-Object { $allApps.Add($_) }
        Write-Host "  Retrieved $($allApps.Count) apps so far..." -ForegroundColor Gray
    }
    
    $nextLink = $response.'@odata.nextLink'
}

Write-Host "Total apps found: $($allApps.Count)`n" -ForegroundColor Green

if ($allApps.Count -eq 0) {
    Write-Warning "No apps found. Check your permissions."
    Disconnect-MgGraph | Out-Null
    return
}

# ── Enrich each app with full details + assignments ───────────────
Write-Host "Fetching full details and assignments for each app..." -ForegroundColor Cyan

$enrichedApps = [System.Collections.Generic.List[object]]::new()
$counter = 0

foreach ($app in $allApps) {
    $counter++
    $pct = [math]::Round(($counter / $allApps.Count) * 100)
    Write-Progress -Activity "Fetching app details" -Status "$counter of $($allApps.Count) ($pct%)" -PercentComplete $pct

    try {
        # Full app properties (the list endpoint omits some type-specific fields)
        $detail = Invoke-MgGraphRequest -Method GET -Uri "$baseUri/$($app.id)"

        # Assignments
        try {
            $assignments = Invoke-MgGraphRequest -Method GET -Uri "$baseUri/$($app.id)/assignments"
            $detail["assignments"] = $assignments.value
        }
        catch {
            $detail["assignments"] = @()
        }

        $enrichedApps.Add($detail)
    }
    catch {
        Write-Warning "  Failed to get details for '$($app.displayName)': $_"
        $app["_error"] = $_.Exception.Message
        $enrichedApps.Add($app)
    }
}

Write-Progress -Activity "Fetching app details" -Completed

# ── Export full JSON ──────────────────────────────────────────────
$jsonFile = Join-Path $OutputPath "IntuneApps_Full_$timestamp.json"
$enrichedApps | ConvertTo-Json -Depth 20 | Out-File -FilePath $jsonFile -Encoding utf8
Write-Host "`nFull export (JSON): $jsonFile" -ForegroundColor Green

# ── Export flattened CSV summary ──────────────────────────────────
$csvData = foreach ($app in $enrichedApps) {
    [PSCustomObject]@{
        Id                  = $app.id
        DisplayName         = $app.displayName
        AppType             = $app.'@odata.type'
        Publisher           = $app.publisher
        Description         = ($app.description -replace "`r|`n", " ") -replace '\s+', ' '
        CreatedDateTime     = $app.createdDateTime
        LastModifiedDateTime = $app.lastModifiedDateTime
        IsFeatured          = $app.isFeatured
        PrivacyUrl          = $app.privacyInformationUrl
        InformationUrl      = $app.informationUrl
        Developer           = $app.developer
        Notes               = ($app.notes -replace "`r|`n", " ") -replace '\s+', ' '
        UploadState         = $app.uploadState
        PublishingState      = $app.publishingState
        IsAssigned          = ($app.isAssigned -eq $true)
        AssignmentCount     = @($app.assignments).Count
        DependentAppCount   = $app.dependentAppCount
        SupersedingAppCount = $app.supersedingAppCount
        SupersededAppCount  = $app.supersededAppCount
        InstallCommandLine  = $app.installCommandLine
        UninstallCommandLine = $app.uninstallCommandLine
        SetupFilePath       = $app.setupFilePath
        FileName            = $app.fileName
        Size                = $app.size
        BundleId            = $app.bundleId
        AppStoreUrl         = $app.appStoreUrl
        PackageId           = $app.packageIdentifier
        ProductVersion      = $app.productVersion
    }
}

$csvFile = Join-Path $OutputPath "IntuneApps_Summary_$timestamp.csv"
$csvData | Export-Csv -Path $csvFile -NoTypeInformation -Encoding utf8
Write-Host "Summary export (CSV): $csvFile" -ForegroundColor Green

# ── Summary table ─────────────────────────────────────────────────
Write-Host "`n── App Type Breakdown ──" -ForegroundColor Cyan
$enrichedApps | 
    Group-Object { $_.'@odata.type' -replace '#microsoft\.graph\.' } | 
    Sort-Object Count -Descending | 
    Format-Table @{L='App Type';E={$_.Name}}, Count -AutoSize

# ── Cleanup ───────────────────────────────────────────────────────
Disconnect-MgGraph | Out-Null
Write-Host "Done. Graph session disconnected." -ForegroundColor Green