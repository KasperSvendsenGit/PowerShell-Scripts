<#	Login to Exchange Online, should only be run once.

$UserCredential = Get-Credential	
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking	

#>
#Input the username of the soft deleted user in $SoftDeletedUserName.
$SoftDeletedUserName = "{Username}"
#	Retrives the Identity of the Soft Deleted user.
$GetDestMailboxID = Get-MailboxLocation -Identity $SoftDeletedUserName | Select-Object -ExpandProperty Identity
#	Retrives the Source Mailbox.
$GetSourceMailbox = Get-Mailbox -SoftDeletedMailbox -Identity $SoftDeletedUserName
#	Outputs the variable above to see that it works.
$GetSourceMailbox
#	Creates a new mailbox restore request with the variables above, and places the restored emails in the folder "Restored".
New-MailboxRestoreRequest -SourceMailbox $GetSourceMailbox.DistinguishedName -TargetMailbox $GetDestMailboxID -TargetRootFolder "Restored" -AllowLegacyDNMismatch





<#	Other useful commands
#	Use the command below to clean up when the mailbox is restored.
Remove-MailboxRestoreRequest {RequestGuid}
#	Use this to see the progress of the Restore Request.
Get-MailboxRestoreRequestStatistics -Identity {RequestGuid}
#>
