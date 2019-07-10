Import-Module "${env:ProgramFiles(x86)}\Devolutions\Remote Desktop Manager\RemoteDesktopManager.PowerShellModule.psd1"
$DataSourceURL = "rdm://open?DataSource=8bce828e-a0e8-4b78-a12a-b16f44acd8be&Repository=&Session=" 

$SessionHostName = Read-host -Prompt "Input The Exact Server Name CAPS SENSITIVE!"
$GetSessionID = Get-RDMSession -Name "$SessionHostName" | Select-Object "ID"
$RemovePrefix = "$GetSessionID".Substring(5)
$Suffix = "$RemovePrefix".TrimEnd("}")
$SessionURL = "$DataSourceURL$Suffix"
Write-Output $SessionURL | clip
echo "URL Copied to clipboard."