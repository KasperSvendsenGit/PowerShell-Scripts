### Script to automate offboarding of accounts without signins and with very infrequent logins. 
##
## $days specifies how many days to wait before disabling the user account.
##
### Written by Kasper Svendsen @ Cadesign Base - 2024


### Variables 
$days = (get-date).AddDays(-60)
$searchBase = ""
$logPath = "C:\Scripts\Auto disable AD users\"
$logFile = $logPath + "Auto_Disabled_Users.log"


# Collect all users that hasn't signed in before as well as those that haven't signed in in $days days.
$oldAndUnusedAccounts = Get-ADUser -Filter 'Enabled -eq $true' -SearchBase $searchBase -Properties SamAccountName,LastLogonDate,whenCreated | Where-object {$_.lastlogondate -lt $days -and $_.whenCreated -lt $days} 

# Seperate users into their respective catagories.
$neverUsedAccounts = $oldAndUnusedAccounts | Where-Object {$_.LastLogonDate -eq $null}
$unusedAccounts = $oldAndUnusedAccounts | Where-Object {$_.LastLogonDate -lt $days -and $_.LastLogonDate -ne $null} | Select SamAccountname, LastLogonDate, whenCreated


### Main

# Disable all "never used" accounts and write in their description field.
$neverUsedAccounts | ForEach-Object {
    $neverUsedAccountsDescription = "$($_.SamAccountName) was disabled on $(Get-Date -Format "yyyy-MM-dd HH:mm:ss") because they've never signed in."
    
    Set-ADUser $_.SamAccountName -Description $neverUsedAccountsDescription
    Disable-ADAccount -Identity $_.SamAccountName

    # Write log to $logFile
    $neverUsedAccountsDescription >> $logFile
}

# Disable all account without signins in the last $days and write in their description field.
$unusedAccounts | ForEach-Object {
    $unusedAccountsDescription = "$($_.SamAccountName) was disabled on $(Get-Date -Format "yyyy-MM-dd HH:mm:ss") because they haven't signed in for $((New-TimeSpan -Start $($_.lastlogondate) -End (Get-Date)).Days) days."

    Set-ADUser $_.SamAccountName -Description $unusedAccountsDescription
    Disable-ADAccount -Identity $_.SamAccountName

    # Write log to $logFile
    $unusedAccountsDescription >> $logFile
}
