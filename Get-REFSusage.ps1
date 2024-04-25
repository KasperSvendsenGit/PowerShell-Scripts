# http://dewin.me/refs/


# Variables
$inputpath1 = "D:\Backups"
$inputpath2 = "E:\Backups"
$blockstatPath = "C:\refsc\blockstat.exe"
$inputpaths = @(Get-ChildItem -Path $inputpath1 -Depth 0)
$inputpaths += @(Get-ChildItem -Path $inputpath2 -Depth 0) 
$outputArray = @()
$reportDate = get-date -Format yyyy-MM-dd
$reportOutputPath = "C:\refsc\BackupUsage_$reportDate" + ".html"
$processCounter = 0
#$actualUsageTotalCounter = 0
#$savingsTotalCounter = 0
#$totalUsageTotalCounter = 0
$Header = @"
<style>
h1 { font-family: Calibri; font-size: 9px; font-style: normal; font-variant: normal; font-weight: 400; line-height: 9.9px; } 
h2 { font-family: Calibri, Candara, Segoe, "Segoe UI", Optima, Arial, sans-serif; font-size: 35px; font-style: normal; font-variant: normal; font-weight: 700; line-height: 15.4px; } 
h3 { font-family: Calibri, Candara, Segoe, "Segoe UI", Optima, Arial, sans-serif; font-size: 14px; font-style: normal; font-variant: normal; font-weight: 700; line-height: 15.4px; } 
p { font-family: Calibri, Candara, Segoe, "Segoe UI", Optima, Arial, sans-serif; font-size: 14px; font-style: normal; font-variant: normal; font-weight: 400; line-height: 15px; }
blockquote { font-family: Calibri, Candara, Segoe, "Segoe UI", Optima, Arial, sans-serif; font-size: 21px; font-style: normal; font-variant: normal; font-weight: 400; line-height: 30px; } 
pre { font-family: Calibri, Candara, Segoe, "Segoe UI", Optima, Arial, sans-serif; font-size: 13px; font-style: normal; font-variant: normal; font-weight: 400; line-height: 18.5714px; }
TABLE {font-family: Calibri, Candara, Segoe, "Segoe UI", Optima, Arial, sans-serif; border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;vertical-align: top;}
TH {font-family: Calibri, Candara, Segoe, "Segoe UI", Optima, Arial, sans-serif; border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED; vertical-align: top;}
TD {font-family: Calibri, Candara, Segoe, "Segoe UI", Optima, Arial, sans-serif; font-size: 14px; font-style: normal; font-variant: normal; font-weight: 400; line-height: 20px; border-width: 1px; padding: 3px; border-style: solid; border-color: black;vertical-align: top;}
</style>
"@


Start-Transcript -Path "C:\refsc\transcript_$reportDate.txt"


$inputpaths | ForEach-Object {
    # Write status to log and console
    $processStatus = "Processing " + $_.name + " - " + $processCounter + " out of " + $inputpaths.count + " completed"
    Write-Host $processStatus

    # Format current paths
    $currentInputPath = '"' + $_.FullName + '"'
    $currentOutputPath = '"' + "C:\refsc\" + $_.name.Replace(" ","_") + ".xml" + '"'

    # Collect statistics
    Start-Process -FilePath $blockstatPath -ArgumentList @("-x","-d",$currentInputPath,"-o",$currentOutputPath) -Wait

    # Process results
    $result = [xml](Get-Content $currentOutputPath.Replace('"',''))
    $fod = 0
    $result.result.shares.ChildNodes | ForEach-Object {
        $sl=$_
        $fod+=([Int64]::Parse($sl.ratio)*[Int64]::Parse($sl.bytes))
    }

    $fodgb = $fod / 1GB
    $savingsInGB = $result.result.totalshare.bytes / 1GB
    $actualREFSUsageOnDisk = $fodgb - $savingsInGB 
    
    # Store output
    $outputObject = [PSCustomObject] @{
        folderName = $_.name.Replace(" ","_")
        actualUsage = [math]::Round($actualREFSUsageOnDisk)
        savings = [math]::Round($savingsInGB)
        totalUsage = [math]::Round($fodgb)
    }

    $outputArray += $outputObject

    # Cleanup temp files
    Remove-Item $currentOutputPath.Replace('"','')

    # Iterate $processCounter
    $processCounter++
}


# Add total for each column
#$outputObject = [PSCustomObject] @{
#        folderName = "_Total"
#        actualUsage = $outputArray | ForEach-Object {
#            $actualUsageTotalCounter + $_.actualUsage
#        }
#        savings = $outputArray | ForEach-Object {
#            $savingsTotalCounter += $_.savings
#        } 
#        totalUsage = $outputArray | ForEach-Object {
#            $totalUsageTotalCounter + $_.totalUsage
#        }
#}
#
#$outputArray += $outputObject


# Output to HTML report
$outputArray | Select-Object `
@{Name = 'Customer Name'; Expression = {$_.folderName}}, `
@{Name = 'Actual Usage On Disk (in GB)'; Expression = {$_.actualUsage}}, `
@{Name = 'REFS Savings (in GB)'; Expression = {$_.savings}}, `
@{Name = 'Total Reported Usage On Disk (in GB)'; Expression = {$_.totalUsage}} | `
Sort-Object -Property @{Expression = "Customer Name"; Descending = $false} | `
ConvertTo-Html -Head $Header -PreContent "<h2>Datacenter Backup Usage</h2>" | `
Out-File $reportOutputPath


Stop-Transcript