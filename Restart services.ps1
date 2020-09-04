# Variables
$rng = Get-Random -Maximum 10000000
$dmdc_agent = Get-Service -Name "dmdc_agent" | Select-Object Name,DisplayName,Status
$DMDC_SM = Get-Service -Name "DMDC_SM" | Select-Object Name,DisplayName,Status
$DMDCCOMMUNICATE = Get-Service -Name "DMDCCOMMUNICATE" | Select-Object Name,DisplayName,Status
$DMDCDATABASE = Get-Service -Name "DMDCDATABASE" | Select-Object Name,DisplayName,Status

# Script start.
Write-Host "Script starter..."
timeout /T 3 > $env:temp\temp$rng.txt

# Stop services.
Write-Host "Stopper DMDC services..."
Stop-Service -Name "dmdc_agent"
Stop-Service -Name "DMDC_SM"
Stop-Service -Name "DMDCCOMMUNICATE"
Stop-Service -Name "DMDCDATABASE"

# Test if services are running and start them if they're not.
if($dmdc_agent.Status -eq "Stopped")
    {Write-Host $dmdc_agent.DisplayName"køre ikke. Starter service..."; Start-Service -Name $dmdc_agent.Name}
        elseif($dmdc_agent.Status -ne "Stopped"){Write-Host $dmdc_agent.DisplayName "køre allerede."}

if($DMDC_SM.Status -eq "Stopped")
    {Write-Host $DMDC_SM.DisplayName"køre ikke. Starter service..."; Start-Service -Name $DMDC_SM.Name}
        elseif($DMDC_SM.Status -ne "Stopped"){Write-Host $DMDC_SM.DisplayName "køre allerede."}

if($DMDC_SM.Status -eq "Stopped")
    {Write-Host $DMDCCOMMUNICATE.DisplayName"køre ikke. Starter service..."; Start-Service -Name $DMDCCOMMUNICATE.Name}
        elseif($DMDCCOMMUNICATE.Status -ne "Stopped"){Write-Host $DMDCCOMMUNICATE.DisplayName "køre allerede."}

if($DMDCDATABASE.Status -eq "Stopped")
    {Write-Host $DMDCDATABASE.DisplayName"køre ikke. Starter service..."; Start-Service -Name $DMDCDATABASE.Name}
        elseif($DMDCDATABASE.Status -ne "Stopped"){Write-Host $DMDCDATABASE.DisplayName "køre allerede."}

# Write status of services
if($dmdc_agent.Status -eq "Running") {Write-Host $dmdc_agent.DisplayName"servicen køre..."}
if($DMDC_SM.Status -eq "Running") {Write-Host $DMDC_SM.DisplayName"servicen køre..."}
if($DMDCCOMMUNICATE.Status -eq "Running") {Write-Host $DMDCCOMMUNICATE.DisplayName"servicen køre..."}
if($DMDCDATABASE.Status -eq "Running") {Write-Host $DMDCCOMMUNICATE.DisplayName"servicen køre..."}

# Script end.
Write-Host "Scriptet er færdig med at køre, du kan lukke vinduet nu..."
pause














