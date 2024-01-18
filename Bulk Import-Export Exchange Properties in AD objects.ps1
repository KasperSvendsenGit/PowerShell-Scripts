#	Script used for bulk import and export Exchange AD properties from AD Objects
#	Run each section manually in ISE.


#	Variables
$SearchBase = "OU=Test Users,OU=Users,OU=_svendsen.local,DC=svendsen,DC=local"
$UserDataExportPath = "C:\temp\ADobjectExchangeData.csv"


#	Export AD object data. Uncomment or run selection this part to export data from objects. - can also be used to check import afterwards
Get-ADUser -Filter * -SearchBase $SearchBase -Properties mail, proxyaddresses, userprincipalname |`
select userprincipalname, mail, @{L="ProxyAddresses"; E={ $_.ProxyAddresses -join ";"}} | `
Export-Csv -Path $UserDataExportPath -NoTypeInformation 




#	Import data - uses same path as export
Import-Csv -Path $UserDataExportPath | ForEach-Object {
    Get-ADUser -Filter "UserPrincipalName -eq '$($_.userprincipalname)'" -Properties Proxyaddresses, mail, userprincipalname |`
    Set-ADUser -Replace @{ProxyAddresses=$($_.ProxyAddresses -split ";")}
    Get-ADUser -Filter "UserPrincipalName -eq '$($_.userprincipalname)'" -Properties Proxyaddresses, mail, userprincipalname |`
    Set-ADUser -Replace @{mail=$($_.mail)}
}
