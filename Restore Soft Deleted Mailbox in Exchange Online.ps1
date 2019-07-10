<#

$UserCredential = Get-Credential	
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking	

#>

$GetSourceExchangeGUID = Get-Mailbox $SoftDeletedUserName -SoftDeletedMailbox | Select-Object ExchangeGuid

$GetDestExchangeGUID = Get-Mailbox $SoftDeletedUserName | Select-Object -ExpandProperty ExchangeGuid

$GetDestMailboxID = Get-MailboxLocation -Identity $SoftDeletedUserName | Select-Object -ExpandProperty Identity

$SelectSourceExchangeGUID = Format-Table -HideTableHeaders -InputObject $GetSourceExchangeGUID -Property ExchangeGuid

$SelectDestExchangeGUID = Format-Table -HideTableHeaders -InputObject $GetDestExchangeGUID -Property ExchangeGuid

$SelectDestMailboxID = Format-Table -HideTableHeaders -InputObject $GetDestMailboxID -Property ExchangeGuid

$InactiveMailbox = Get-Mailbox -SoftDeletedMailbox -Identity $SoftDeletedUserName

$InactiveMailbox

New-MailboxRestoreRequest -SourceMailbox $InactiveMailbox.DistinguishedName -TargetMailbox $GetDestMailboxID -TargetRootFolder "Restored" -AllowLegacyDNMismatch








#Username + Other Variables
$SoftDeletedUserName = "hbk"




# Test Area
<#

$GetSourceExchangeGUID = Get-Mailbox $SoftDeletedUserName -SoftDeletedMailbox | Select-Object ExchangeGuid
$GetDestExchangeGUID = Get-Mailbox $SoftDeletedUserName | Select-Object ExchangeGuid
#$SelectExchangeGUID = Format-Table -HideTableHeaders -InputObject $GetSourceExchangeGUID -Property ExchangeGuid
#$SelectExchangeGUID = $GetSourceExchangeGUID | #fl ExchangeGuid
#$RemovePrefix = $SelectExchangeGUID 
Write-Output $GetSourceExchangeGUID
Write-Output $GetDestExchangeGUID

Format-Table -HideTableHeaders -InputObject $SelectExchangGUID -Property ExchangeGuid

Remove-MailboxRestoreRequest 46d52043-5e82-4e12-a14d-fdd2855bb487
Remove-MailboxRestoreRequest 57931915-dd43-4f6d-a1ee-953ad34a62fa
Remove-MailboxRestoreRequest d2e014fd-df74-4f8f-b719-6c06fd8d007a
Remove-MailboxRestoreRequest eb9f98c8-2859-4b3a-b99b-ae8c5ece7db2
Remove-MailboxRestoreRequest 91620c5c-3844-4eeb-98d8-0a9dbad0f65d
Remove-MailboxRestoreRequest 4c2e59aa-af7a-4504-8bc2-c51f3505120c
Remove-MailboxRestoreRequest 8f4b874a-1beb-49a4-be23-36f8830ee83a

#>
