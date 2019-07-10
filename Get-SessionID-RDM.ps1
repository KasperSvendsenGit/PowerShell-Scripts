#	Loads the Remote Desktop Manager Powershell module.
Import-Module "${env:ProgramFiles(x86)}\Devolutions\Remote Desktop Manager\RemoteDesktopManager.PowerShellModule.psd1"
#	Example Data Soruce URL. This is unique for every datasource, you'll need to create your own the first time. 
$DataSourceURL = "rdm://open?DataSource=8bce828e-a0e8-4b78-a12a-b16f44acd8be&Repository=&Session=" 
#	Asks for Hostname of the session, input is CASE SENSITIVE and will break if there are dublicates.
$SessionHostName = Read-host -Prompt "Input The Exact Server Name CASE SENSITIVE!"
#	Gets the ID required to finish the URL from $DataSourceURL.
$GetSessionID = Get-RDMSession -Name "$SessionHostName" | Select-Object "ID"
#	The ID has an undesired prefix, this removes it. 
$RemovePrefix = "$GetSessionID".Substring(5)
#	The ID has an undesired surffix, this removes it.
$Suffix = "$RemovePrefix".TrimEnd("}")
#	This combines the static data source URL with the session ID.
$SessionURL = "$DataSourceURL$Suffix"
#	Copies the session URL to clipboard.
Write-Output $SessionURL | clip
#	Outputs the success message.
Write-Output "URL Copied to clipboard."